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

import labcoat.message.*;
import precog.util.Locale;
import precog.communicator.Communicator;
import precog.communicator.Module;
import precog.html.HtmlPanelGroup;
import precog.html.HtmlPanel;

using thx.react.Promise;

using precog.html.JQuerys;

class StatusModule extends Module {
	var ul : jQuery.JQuery;
    override public function connect(communicator: Communicator) {
        communicator
            .demand(ToolsHtmlPanelGroup)
            .await(communicator.demand(Locale))
            .with(communicator)
            .then(init);
    }

    function init(message: ToolsHtmlPanelGroup, locale : Locale, communicator : Communicator)
    {
    	var group = new HtmlPanelGroupItem(locale.singular("status"));
    	group.panel.element.addClass("status");
    	ul = new jQuery.JQuery('<ul class="status-list unstyled"></ul>').appendTo(group.panel.element);
        message.group.addItem(group);
        communicator.consume(function(messages : Array<StatusMessage>) {
        	messages.map(consumeMessage.bind(locale));
        	group.activate();
        	group.panel.element.scrollTop(group.panel.element.get(0).scrollHeight);
        });
    }

    function consumeMessage(locale : Locale, status : StatusMessage) {
    	var type = Std.string(status.type).toLowerCase(),
    		li = new jQuery.JQuery('<li class="text-$type"><i class="icon-${icon(type)}"></i><span class="text"></span><span class="badge badge-light time">${locale.format("{0:T}", [status.time])}</span></li>').appendTo(ul);
    	li.find(".text").append(status.message);
    }

    function icon(type : String)
    {
    	return switch(type) {
    		case "error":	"exclamation-sign";
    		case "warning":	"warning-sign";
    		case "info":	"info-sign";
    		case _:			"question-sign";
    	}
    }
}