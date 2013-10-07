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
package precog.editor;

import labcoat.message.PrecogRequest;
import labcoat.message.PrecogResponse;
import precog.communicator.Communicator;
import precog.editor.codemirror.Externs;
import precog.html.HtmlButton;
import precog.html.HtmlDropdown;
import precog.html.Icons;
import jQuery.JQuery;
import jQuery.Event;
import thx.react.Signal;
import precog.util.Locale;
import precog.html.Bootstrap;
using precog.editor.RegionMode;

class Region {
    public var index: Int;
    public var directory: String;
    public var filename: String;
    public var locale: Locale;

    public var mode: RegionMode;
    public var element: JQuery;
    public var editor: RegionEditor;
    public var events(default, null) : {
        public var changeMode(default, null) : Signal2<Region, RegionMode>;
        public var remove(default, null) : Signal1<Region>;
        public function clear() : Void;
    };

    var communicator: Communicator;
    var editorToolbar: JQuery;
    var toggleTrimButton: HtmlButton;
    var showHideButton: HtmlButton;
    var deleteButton: HtmlButton;

    // TOOD: Triggering ourselves
    function changeTo(mode: RegionMode) {
        return function(event: Event) {
            events.changeMode.trigger(this, mode);
            return false;
        };
    }

    function changeEditorModeButton() {
        var items = [];

        Type.allEnums(RegionMode).map(function(other) {
            if(!Type.enumEq(mode, other))
                items.push(DropdownButton(locale.format('switch to {0}', [other.toEnglish()]), '', changeTo(other)));
        });

        var dropdown = new HtmlDropdown(locale.singular(mode.toEnglish()), '', '', Mini, items, DropdownAlignLeft);
        dropdown.element
            .addClass("region-type")
            .find("button:first-child").addClass("btn-link");
        return dropdown;
    }

    function createEditor() {
        return switch(mode) {
            case QuirrelRegionMode: new QuirrelEditor(communicator, this, editorToolbar);
            case MarkdownRegionMode: new MarkdownEditor(communicator, this);
            case JSONRegionMode: new JSONEditor(communicator, this);
            case VegaRegionMode: new VegaEditor(this);
        }
    }

    function toggleTrimContent(_) {
        toggleTrimButton.leftIcon = element.find('.content .editor').toggleClass('trimmed').is('.trimmed') ? Icons.resizeFull : Icons.resizeSmall;
    }

    function showHideContent(_) {
        showHideButton.leftIcon = element.find('.content .editor').toggle().is(':visible') ? Icons.eyeClose : Icons.eyeOpen;
    }

    // TOOD: Triggering ourselves
    function deleteContent() {
        events.remove.trigger(this);
    }

    public function path() {
        return '${directory}/${filename}';
    }

    public function new(communicator: Communicator, directory: String, filename: String, mode: RegionMode, locale : Locale) {
        this.events = {
            changeMode : new Signal2(),
            remove : new Signal1(),
            clear : function() {
                for(field in Reflect.fields(this)) {
                    var signal : Signal<Dynamic> = Reflect.field(this, field);
                    if(!Std.is(signal, Signal))
                        continue;
                    signal.clear();
                }
            }
        };

        this.mode = mode;
        this.communicator = communicator;
        this.directory = directory;
        this.filename = filename;
        this.locale = locale;

        element = new JQuery('<div class="region"></div>');

        var titlebar = new JQuery('<div class="titlebar"></div>');
        titlebar.append(changeEditorModeButton().element);
        editorToolbar = new JQuery('<div class="editor toolbar"></div>').appendTo(titlebar);

        var contextToolbar = new JQuery('<div class="context toolbar"></div>').appendTo(titlebar);

        toggleTrimButton = new HtmlButton(locale.singular('toggle trim'), Icons.resizeFull, Mini, true);
        toggleTrimButton.type = Flat;
        toggleTrimButton.element.click(toggleTrimContent);
        toggleTrimButton.element.addClass('toggle-trim');
        contextToolbar.append(toggleTrimButton.element);

        showHideButton = new HtmlButton(locale.singular('show/hide'), Icons.eyeClose, Mini, true);
        showHideButton.type = Flat;
        showHideButton.element.click(showHideContent);
        showHideButton.element.addClass('show-hide');
        contextToolbar.append(showHideButton.element);

        deleteButton = new HtmlButton(locale.singular('delete'), Icons.remove, Mini, true);
        deleteButton.type = Flat;
        deleteButton.element.click(function(_) {
            Dialog.confirm("Are you sure you want to delete this region?", deleteContent);
        });
        deleteButton.element.addClass('toggle-trim');
        contextToolbar.append(deleteButton.element);

        element.append(titlebar);

        editor = createEditor();
        var content = new JQuery('<div class="content"></div>');
        content.append(editor.element);
        element.append(content);

        communicator.request(
            new RequestFileGet(path()),
            ResponseFileGet
        ).then(function(response: ResponseFileGet) {
            // HACK: Precog API loves to send us back [] instead of 404
            if(response.content.contents == '[]' && mode != JSONRegionMode)
                return;

            editor.setContent(response.content.contents);
            editor.evaluate();
        });
    }
}
