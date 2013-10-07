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
package precog.fs;

class Meta
{
	var map : Map<String, Dynamic>;
	var node : Node;
	public function new(node : Node)
	{
		this.node = node;
		map = new Map<String, Dynamic>();
	}
	public function get(key : String)
		return map.get(key);
	public function set(key : String, value : Dynamic)
	{
		trigger(new MetaChangeEvent(node, key, map.get(key), value));
		map.set(key, value);
		return this;
	}

	public function getAll()
	{
		var copy = new Map();
		for(key in map.keys())
			copy.set(key, map.get(key));
		return copy;
	}

	public function remove(key : String)
	{
		trigger(new MetaChangeEvent(node, key, map.get(key), null));
		return map.remove(key);
	}
	public function exists(key : String)
		return map.exists(key);
	public function keys()
		return map.keys();
	public function iterator()
		return map.iterator();

	public function setMap(other : Map<String, Dynamic>)
	{
		for(key in other.keys())
			map.set(key, other.get(key));	
	}

	public function setObject(ob : Dynamic)
	{
		for(key in Reflect.fields(ob))
			map.set(key, Reflect.field(ob, key));
	}

	macro function trigger<T>(ethis : haxe.macro.Expr, values : Array<haxe.macro.Expr>)
	{
		return macro { if(null != $ethis.node.filesystem) $ethis.node.filesystem.dispatcher.trigger($a{values}); };
	}
}