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
import precog.editor.Editor;
import jQuery.JQuery;

class CodeEditor implements Editor {
    public var element(default, null): JQuery;
    var region: Region;
    var communicator: Communicator;
    public var path(default, null): String;

    public function new(communicator: Communicator, path: String, mode: RegionMode, locale: precog.util.Locale) {
        element = new JQuery('<div class="code-editor"></div>');

        var segments = path.split('/');
        var filename = segments.pop();
        var directory = segments.join('/');

        // TODO: Allow files which are not Markdown
        region = new Region(communicator, directory, filename, mode, locale);
        element.append(region.element);
        this.communicator = communicator;
        this.path = path;
    }

    public function save(dest: String) {
        communicator.request(
            new RequestFileMove(path, dest),
            ResponseFileMove
        ).then(function(response: ResponseFileMove) {
            path = dest;
        });
    }

    public function show() {
        region.editor.focus();
    }
    public function clear() {}
}
