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
package precog.communicator;

import utest.Assert;
import thx.react.Promise;
import labcoat.message.ApplicationHtmlContainerMessage;

class TestCommunicator
{
	public function new() { }

	public function testOnTrigger()
	{
		var comm = new Communicator();
		comm.on(function(msg : String) {
			Assert.equals("Haxe", msg);
		});
		comm.trigger("Haxe");
	}

	public function testDemandProvide()
	{
		var comm = new Communicator();
		comm.demand(String).then(function(s : String) Assert.equals("Haxe", s));
		comm.provide("Haxe");
	}

	public function testRequestRespond()
	{
		var comm = new Communicator();
		comm.request("haxe", String).then(function(s : String) Assert.equals("HAXE", s));
		comm.respond(function(s : String) {
			return Promise.value(s.toUpperCase());
		}, String, String);
	}

	public function testDemandProvideInstance()
	{
		var comm = new Communicator();
		comm.provide(new ApplicationHtmlContainerMessage(null));
		comm.demand(ApplicationHtmlContainerMessage)
			.then(function(o : ApplicationHtmlContainerMessage) {
				Assert.notNull(o);
				Assert.is(o, ApplicationHtmlContainerMessage);
			});
	}
}