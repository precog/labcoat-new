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

class Node
{
	public var meta(default, null) : Meta;
	@:isVar public var name(get, set) : String;
	public var filesystem(default, null) : FileSystem;
	public var parent(default, null) : Directory;
	public var isFile(default, null) : Bool;
	public var isDirectory(default, null) : Bool;
	public var isRoot(default, null) : Bool;
	public var isSystem(get, null) : Bool;
	public var root(get, null) : Node;
	public var level(get, null) : Int;
	public function new(name : String, parent : Directory, ?metadata : Map<String, Dynamic>)
	{
		meta = new Meta(this);
		if(null != metadata)
			meta.setMap(metadata);
		this.init();
		this.name = name;
		if(null != parent)
			parent.addNode(this);
	}

	function init() { }

	function get_name() return name;
	function set_name(value)
	{
		if(value == "" || value == null)
			throw "invalid value (empty or null)";
		if(value == this.name)
			return value;
		var old = this.name;
		this.name = value;
		trigger(new NodeNameEvent(old, this));
		return value;
	}

	function get_isSystem()
		return name.substr(0, 1) == ".";

	function escape(s : String)
		return StringTools.replace(s, "/", "\\/");
	public function toString() return name;
	public function remove()
	{
		if(null != parent)
		{
			var p = parent;
			parent.removeNode(this);
			trigger(new NodeRemoveEvent(this, p));
		}
	}

	function get_root()
	{
		return isRoot ? this : (null == parent ? null : parent.root);
	}

	function get_level()
	{
		return null == parent ? 0 : 1 + parent.level;
	}

	macro function trigger<T>(ethis : haxe.macro.Expr, values : Array<haxe.macro.Expr>)
	{
		return macro { if(null != $ethis.filesystem) $ethis.filesystem.dispatcher.trigger($a{values}); };
	}
}