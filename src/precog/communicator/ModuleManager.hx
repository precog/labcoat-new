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

import precog.communicator.ModuleEvent;

class ModuleManager 
{
	var communicator : Communicator;
	var modules : Array<Module>;
	public function new()
	{
		communicator = new Communicator();
		communicator.provide(this);
		modules = [];
	}

	public function addModule(module : Module)
	{
		modules.push(module);
		communicator.trigger(new ModuleConnecting(module));
		module.connect(communicator);
		communicator.trigger(new ModuleConnected(module));
	}

	public function removeModule(module : Module)
	{
		if(modules.remove(module))
		{
			communicator.trigger(new ModuleDisconnecting(module));
			module.disconnect(communicator);
			communicator.trigger(new ModuleDisconnected(module));
		}
	}
}