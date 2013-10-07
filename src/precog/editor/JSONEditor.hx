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
import jQuery.JQuery;

class JSONEditor implements RegionEditor {
    public var element: JQuery;
    var communicator: Communicator;
    var region: Region;
    var editor: TextEditor;

    public function new(communicator: Communicator, region: Region) {
        this.communicator = communicator;
        this.region = region;

        var options: Dynamic = {mode: {name: 'javascript', json: true}, region: region, lineWrapping : true};

        element = new JQuery('<div class="json-editor"><div class="out">${region.filename} :=</div></div>');

//        var area = new TextAreaEditor();
//        area.element.appendTo(element);
//        editor = area;
        editor = CodeMirrorFactory.addTo(element.get(0), options);
        editor.getWrapperElement().className += ' editor';
    }

    public function getContent() {
        return editor.getValue();
    }
    public function setContent(content: String) {
        return editor.setValue(content);
    }

    public function evaluate() {
        communicator.request(
            new RequestFileUpload(region.path(), "application/json", editor.getValue()),
            ResponseFileUpload
        );
    }

    public function focus() {
        editor.refresh();
        editor.focus();
    }
}
