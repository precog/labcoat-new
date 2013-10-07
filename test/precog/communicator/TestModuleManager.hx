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
import precog.communicator.ModuleEvent;
import precog.communicator.Module;

class TestModuleManager
{
	public function new() { }
	public function testConnectDisconnect()
	{
		var manager = new ModuleManager(),
			module = new SampleModule();
		Assert.isFalse(module.connected);
		manager.addModule(module);
		Assert.isTrue(module.connected);
		Assert.isFalse(module.disconnected);
		manager.removeModule(module);
		Assert.isTrue(module.disconnected);
	}

	public function testProvideManager()
	{
		var manager = new ModuleManager(),
			module = new SampleModule();
		Assert.isNull(module.manager);
		manager.addModule(module);
		Assert.equals(manager, module.manager);
	}

	public function testModuleEvents()
	{
		var manager = new ModuleManager(),
			module = new SampleModule(),
			monitor = new EventCounterModule(module);
		manager.addModule(monitor);
		Assert.equals(0, monitor.connecting);
		Assert.equals(0, monitor.connected);
		manager.addModule(module);
		Assert.equals(1, monitor.connecting);
		Assert.equals(1, monitor.connected);

		Assert.equals(0, monitor.disconnecting);
		Assert.equals(0, monitor.disconnected);
		manager.removeModule(module);
		Assert.equals(1, monitor.disconnecting);
		Assert.equals(1, monitor.disconnected);
	}
}

class SampleModule extends Module
{
	public var connected : Bool = false;
	public var disconnected : Bool = false;
	public var manager : ModuleManager;

	override public function connect(comm : Communicator)
	{
		connected = true;
		comm.demand(ModuleManager).then(function(m : ModuleManager) {
			this.manager = m;
		});
	}

	override public function disconnect(comm : Communicator)
	{
		disconnected = true;
	}
}

class EventCounterModule extends Module
{
	public var connecting : Int = 0;
	public var connected : Int = 0;
	public var disconnecting : Int = 0;
	public var disconnected : Int = 0;

	public var identity : Module;

	public function new(identity : Module)
	{
		super();
		this.identity = identity;
	}

	override public function connect(comm : Communicator)
	{
		comm.on(function(e : ModuleConnecting) {
			connecting++;
			Assert.equals(identity, e.module);
		});
		comm.on(function(e : ModuleConnected) {
			// discard self
			if(e.module == this) return;
			connected++;
			Assert.equals(identity, e.module);
		});
		comm.on(function(e : ModuleDisconnecting) {
			disconnecting++;
			Assert.equals(identity, e.module);
		});
		comm.on(function(e : ModuleDisconnected) {
			disconnected++;
			Assert.equals(identity, e.module);
		});
	}
}