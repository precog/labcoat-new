/*
 *  _       _                     _   
 * | |     | |                   | |  
 * | | __ _| |__   ___ ___   __ _| |_               Labcoat (R)
 * | |/ _` | '_ \ / __/ _ \ / _` | __|              Powerful development environment for Quirrel.
 * | | (_| | |_) | (_| (_) | (_| | |_               Copyright (C) 2010 - 2013 SlamData, Inc.
 * |_|\__,_|_.__/ \___\___/ \__,_|\__|              All Rights Reserved.
 *
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 
 * 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See 
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this 
 * program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
package labcoat.module.view;

import jQuery.Event;
import jQuery.JQuery;
import labcoat.message.*;
import labcoat.message.MenuItem;
import labcoat.message.PrecogRequest;
import labcoat.message.PrecogResponse;
import precog.communicator.Communicator;
import precog.communicator.Module;
import precog.editor.*;
import precog.editor.Editor;
import precog.editor.RegionMode;
import precog.editor.codemirror.Externs;
import precog.editor.codemirror.QuirrelMode;
import precog.geom.Rectangle;
import precog.html.Bootstrap;
import precog.html.HtmlButton;
import precog.html.HtmlDropdown;
import precog.html.HtmlPanel;
import precog.html.HtmlPanelGroup;
import precog.html.Icons;
import precog.util.Locale;
import labcoat.config.ViewConfig;

using StringTools;
using thx.react.IObservable;
using thx.react.Promise;

class EditorModule extends Module {
    var current : Editor;
    var editors : Array<Editor>;
    var communicator : Communicator;
    var locale : Locale;
    var main : HtmlPanelGroup;
    var panels : Map<Editor, HtmlPanelGroupItem>;

    var accountId : String;
    var tmpPath : String;
    var metadataPath : String;
    var currentPath : String;

    var fileCounter : Int = 0;
    var notebookCounter : Int = 0;

    public function new()
    {
        super();
        panels = new Map();
        editors = [];
    }

    override public function connect(communicator: Communicator) {
        this.communicator = communicator;
        communicator
            .demand(MainEditorHtmlPanel)
            .await(communicator.demand(Locale))
            .then(init);
        communicator.on(function(e : EditorOpenNotebook)
            openNotebook(e.path));
        communicator.on(function(e : EditorOpenFile)
            getContentTypeOpenCodeEditor(e.path));
        communicator.on(function(e : EditorUpdate)
            changeEditor(e.current));
        communicator.on(function(e : ResponseDirectoryDelete)
            closeDeleted(e.path));

        communicator.queueMany([
            // new MenuItem(MenuEdit(SubgroupEditHistory), "Undo", function(){}, 0),
            // new MenuItem(MenuEdit(SubgroupEditHistory), "Redo", function(){}, 1)
        ]);

        communicator.on(function(_ : NodeDeselected) {
            setCurrentPath(null);
        });

        communicator.on(function(e : DirectorySelected) {
            setCurrentPath(e.path);
        });
    }

    public function init(editorPanel: MainEditorHtmlPanel, locale : Locale) {
        this.locale = locale;

        QuirrelMode.init();

        // Global keyhandlers
        Reflect.setField(CodeMirror.keyMap.basic, "Shift-Up", "goLineUp");
        Reflect.setField(CodeMirror.keyMap.basic, "Shift-Down", "goLineDown");
        Reflect.setField(CodeMirror.keyMap.basic, "Up", moveUpAcrossRegions);
        Reflect.setField(CodeMirror.keyMap.basic, "Down", moveDownAcrossRegions);
        Reflect.setField(CodeMirror.keyMap.basic, "Shift-Enter", evaluateRegion);
        Reflect.setField(CodeMirror.keyMap.macDefault, "Cmd-Enter", createRegionFromEditor);
        Reflect.setField(CodeMirror.keyMap.pcDefault, "Ctrl-Enter", createRegionFromEditor);

        var rect = new Rectangle();
        editorPanel.panel.rectangle.addListener(rect.updateSize);
        rect.updateSize(editorPanel.panel.rectangle);
        main = new HtmlPanelGroup(editorPanel.panel.element, rect, [
            DropdownButton('new notebook', '', function(e: Event) {
                createNotebook();
            }),
            DropdownButton('new quirrel file', '', function(e: Event) {
                createCodeEditor(QuirrelRegionMode);
            }),
            DropdownButton('new markdown file', '', function(e: Event) {
                createCodeEditor(MarkdownRegionMode);
            }),
            DropdownButton('new json file', '', function(e: Event) {
                createCodeEditor(JSONRegionMode);
            })
        ]);
        main.gutterMargin = 0;
        main.toggleSize = Default;
//        main.toggleType = Primary;
        main.gutterPosition = Top;
        main.events.activate.on(function(panel : HtmlPanelGroupItem) {
            if(null == panel)
                return;
            // silly way of getting back the clicked notebook
            for(editor in editors)
            {
                if(panel != panels.get(editor)) continue;
                communicator.trigger(new EditorUpdate(editor, editors));
                break;
            }
        });

        communicator.consume(function(configs : Array<PrecogNamedConfig>) {
            // TODO: Maybe check this is the "default" account
            accountId = configs[0].config.accountId;
            setCurrentPath(null);
            tmpPath = '${accountId}/temp';
            metadataPath = '${tmpPath}/metadata.json';
            loadMetadata();
        });
    }

    function setCurrentPath(path : String)
    {
        if(null == path)
            currentPath = "/" + accountId;
        else
            currentPath = path;
    }

    function loadMetadata() {
        communicator.request(
            new RequestFileGet(metadataPath),
            ResponseFileGet
        ).then(function(response: ResponseFileGet) {
            var metadata = haxe.Json.parse(response.content.contents)[0];
            if(metadata == null) {
                // TODO: Open a new notebook
                createNotebook();
                return;
            }

            fileCounter = metadata.fileCounter;
            notebookCounter = metadata.notebookCounter;

            var editors: Array<{type: String, path: String}> = metadata.editors;
            for(editor in editors) {
                switch(editor.type) {
                case 'CodeEditor': getContentTypeOpenCodeEditor(editor.path);
                case 'Notebook': openNotebook(editor.path);
                }
            }
        });
    }

    function contentTypeToRegionMode(contentType: String) {
        return switch(contentType) {
        case 'application/json': JSONRegionMode;
        case 'text/x-quirrel-script': QuirrelRegionMode;
        case _: throw 'Bad content type ${contentType}: no editor mode available';
        }
    }

    function saveMetadata() {
        communicator.request(
            new RequestFileUpload(metadataPath, 'application/json', serializeMetadata()),
            ResponseFileUpload
        );
    }

    function serializeMetadata() {
        return haxe.Json.stringify({
            editors: editors.map(function(e: Editor) return {
                type: e.cata(
                    function(codeEditor: CodeEditor) return 'CodeEditor',
                    function(notebook: Notebook) return 'Notebook'
                ),
                path: e.path
            }),
            fileCounter: fileCounter,
            notebookCounter: notebookCounter
        });
    }

    function getContentTypeOpenCodeEditor(path: String) {
        communicator.request(
            new RequestFileGet(path),
            ResponseFileGet
        ).then(function(response: ResponseFileGet) {
            openCodeEditor(path, contentTypeToRegionMode(response.content.type));
        });
    }

    function openCodeEditor(path: String, mode: RegionMode) {
        var codeEditor = new CodeEditor(communicator, path, mode, locale);
        addEditor(codeEditor);
    }

    function createCodeEditor(mode: RegionMode) {
        ++fileCounter;
        openCodeEditor('${tmpPath}/code/file${fileCounter}', mode);
        saveMetadata();
    }

    function openNotebook(path: String) {
        var notebook = new Notebook(communicator, path, locale);
        addEditor(notebook);
    }

    function createNotebook() {
        ++notebookCounter;
        openNotebook('${tmpPath}/notebooks/notebook${notebookCounter}');
        saveMetadata();
    }

    function tabButton(editor: Editor) {
        var insert = new HtmlButton(locale.singular('insert region'), Icons.levelDown + " icon-90", Mini, true);
        insert.element.click(function(event: Event) {
            event.preventDefault();
            createRegion(QuirrelRegionMode);
        });
        var save = new HtmlButton(locale.singular('save'), Icons.save, Mini, true);
        save.element.click(function(event: Event) {
            event.preventDefault();
            saveEditor();
        });

        var filename = editor.path.split('/').pop();
        var item = editor.cata(
            function(codeEditor: CodeEditor) return new HtmlPanelGroupItem(filename, Icons.file),
            function(notebook: Notebook) return new HtmlPanelGroupItem(filename, Icons.book)
        );
        item.toggle.rightIcon = 'remove';
        item.toggle.element.find('.right-icon').click(function(_: jQuery.Event) {
            closeEditor(editor);
        });

        var containers = new ToolbarContainers(item, ViewConfig.mainToolbarHeight, ViewConfig.mainToolbarMargin);

        containers.toolbar.element.addClass("main-toolbar");
        containers.main.element.append(editor.element);
        containers.main.element.addClass("edit-area");

        var btnGroup = new JQuery('<div class="btn-group"></div>').appendTo(containers.toolbar.element);
        // TODO: Stop using catamorphisms in EditorModule for
        // polymorphism. Add these details to each editor.
        editor.cata(
            function(codeEditor: CodeEditor) {
                save.element.appendTo(btnGroup);
            },
            function(notebook: Notebook) {
                insert.element.appendTo(btnGroup);
                save.element.appendTo(btnGroup);
            }
        );

        return item;
    }

    function addEditor(editor: Editor) {
        var item = tabButton(editor);
        main.addItem(item);
        panels.set(editor, item);
        editors.push(editor);

        communicator.trigger(new EditorUpdate(editor, editors));
    }

    function changeEditor(editor: Editor) {
        current = editor;
        if(null == current)
            return;
        panels.get(editor).activate();
        current.show();
    }

    function closeDeleted(path: String) {
        for(editor in editors) {
            if(!'/${editor.path}'.startsWith(path + '/') && editor.path != path)
                continue;
            closeEditor(editor);
        }
    }

    function closeEditor(editor: Editor) {
        editor.clear();
        editors.remove(editor);
        var item = panels.get(editor);
        panels.remove(editor);
        editor.cata(
            function(codeEditor: CodeEditor) { /* TODO: Clear CodeEditor events */ },
            function(notebook: Notebook) { notebook.events.clear(); }
        );
        main.removeItem(item);
        saveMetadata();
    }

    function saveEditor() {
        var parent = currentPath;
        Dialog.prompt(locale.format("Current directory: <code>{0}</code><br>Save file as:", [parent]), function(filename: String){
            current.save('${parent}/${filename}');
        });
    }

    function deleteRegion(region: Region) {
        current.cata(
            function(codeEditor: CodeEditor) {
                // Can't delete regions in a single editor
            },
            function(notebook: Notebook) { notebook.deleteRegion(region); }
        );
    }

    function changeRegionMode(oldRegion: Region, mode: RegionMode) {
        current.cata(
            function(codeEditor: CodeEditor) {
                // Can't change single editor modes
            },
            function(notebook: Notebook) { notebook.changeRegionMode(oldRegion, mode); }
        );
    }

    function appendRegion(region: Region, notebook: Notebook, ?target: JQuery) {
        notebook.appendRegion(region, target);
    }

    function createRegion(regionMode: RegionMode, ?target: JQuery) {
        current.cata(
            function(codeEditor: CodeEditor) {
                // Can't create regions in a single editor
            },
            function(notebook: Notebook) { notebook.createRegion(regionMode, target); }
        );
    }
    
    function createRegionFromEditor(editor: CodeMirror) {
        var region : Region = editor.getOption('region');
        createRegion(region.mode, region.element);
    }

    function moveUpAcrossRegions(editor: CodeMirror) {
        current.cata(
            function(codeEditor: CodeEditor) {},
            function(notebook: Notebook) {
                if(editor.getCursor("start").line != editor.firstLine()) return;
                var region: Region = editor.getOption('region');
                notebook.focusPreviousRegion(region);
            }
        );
        editor.moveV(-1, "line");
    }

    function moveDownAcrossRegions(editor: CodeMirror) {
        current.cata(
            function(codeEditor: CodeEditor) {},
            function(notebook: Notebook) {
                if(editor.getCursor("end").line != editor.lastLine()) return;
                var region: Region = editor.getOption('region');
                notebook.focusNextRegion(region);
            }
        );
        editor.moveV(1, "line");
    }

    function evaluateRegion(editor: CodeMirror) {
        var region : Region = editor.getOption('region');
        region.editor.evaluate();
    }
}
