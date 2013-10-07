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
import precog.editor.markdown.Externs;
import jQuery.JQuery;
import jQuery.Event;

using StringTools;

class MarkdownEditor implements RegionEditor {
    public var element: JQuery;
    var communicator: Communicator;
    var editor: CodeMirror;
    var region: Region;
    var rendered: JQuery;

    public function new(communicator: Communicator, region: Region) {
        this.communicator = communicator;
        this.region = region;

        var options: Dynamic = {mode: 'markdown', region: region};

        rendered = new JQuery('<div class="markdown-rendered"></div>').hide();
        // Giving block elements a tabIndex give them a "focus" event.
        rendered.attr('tabindex', '-1');
        rendered.focus(function(e: Event) focus());

        element = new JQuery('<div class="editor trimmed"></div>').append(rendered);

        editor = CodeMirrorFactory.addTo(element.get(0), options);
        editor.on('blur', editorBlur);
        editor.getWrapperElement().className += ' markdown-editor';
    }

    function editorBlur(editor: CodeMirror) {
        // Don't remove the editor if the content is empty (would
        // result in an empty, non-clickable div)
        if(getContent().trim().length == 0) return;

        editor.getWrapperElement().style.display = 'none';
        rendered.show().html(Markdown.toHTML(getContent()));

        communicator.request(
            new RequestFileUpload(region.path(), "text/x-markdown", getContent()),
            ResponseFileUpload
        );
    }

    public function getContent() {
        return editor.getValue();
    }

    public function setContent(content: String) {
        return editor.setValue(content);
    }

    public function evaluate() {
        editorBlur(editor);
    }

    public function focus() {
        rendered.hide();
        editor.getWrapperElement().style.display = 'block';
        editor.refresh();
        editor.focus();
    }
}
