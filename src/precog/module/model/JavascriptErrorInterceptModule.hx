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
package precog.module.model;

import precog.communicator.*;
import thx.react.Promise;
import precog.api.*;
import labcoat.message.*;
import thx.react.Buffer;

class JavascriptErrorInterceptModule extends Module
{
	var buffer : Buffer;
	public function new()
	{
		super();
		buffer = new Buffer();
		js.Browser.window.onerror = cast function(msg : String, url : String, line : String) {
			var message = '$msg <small>(line $line) at $url</small>';
			buffer.queue(new StatusMessage(message, Error));
		};
	}
	override function connect(communicator : Communicator)
	{
		buffer.consume(function(arr : Array<StatusMessage>) communicator.queueMany(arr));
	}
}