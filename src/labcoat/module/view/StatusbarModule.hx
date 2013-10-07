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

using thx.react.Promise;

using precog.html.JQuerys;

class StatusbarModule extends Module {

	var requests : Int = 0;
	var total : Int = 0;

    override public function connect(communicator: Communicator) {
		communicator.on(function(req : PrecogRequest) {
    		requests++;
    		total++;
    	});

    	communicator.on(function(res : PrecogResponse) {
    		requests--;
    	});

        communicator
            .demand(MainStatusbarHtmlPanel)
            .await(communicator.demand(Locale))
            .with(communicator)
            .then(onMessage);
    }

    function onMessage(bar: MainStatusbarHtmlPanel, locale : Locale, communicator : Communicator)
    {
    	var el = bar.panel.element;

    	var timer = null;
    	function updateRequests()
    	{
    		if(null != timer) timer.stop();
    		timer = haxe.Timer.delay(function(){
	    		if(requests != 0)
	    			el.html('<small><i class="icon-spinner icon-spin"></i> <span class="label label-important"> $requests active requests</span> out of <span class="label label-light">$total</span></small>');
	    		else
	    			el.html('<small><i class="icon-cloud"></i> <span class="label label-light"> total requests made $total</span></small>');
    		}, 200);
    	}

    	communicator.on(function(req : PrecogRequest) {
    		updateRequests();
    	});

    	communicator.on(function(res : PrecogResponse) {
    		updateRequests();
    	});

    	updateRequests();
    }
}