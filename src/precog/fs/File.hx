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

class File extends Node
{
	public var extension(get, set) : String;
	public var baseName(get, set) : String;
	public function new(name : String, parent : Directory, ?meta : Map<String, Dynamic>)
	{
		super(name, parent, meta);
	}

	function get_extension()
	{
		var parts = name.split(".");
		return parts.length == 1 ? "" : parts.pop();
	}
	function set_extension(value : String)
	{
		name = baseName + (null == value || "" == value ? "" : "." + value);
		return value;
	} 
	function get_baseName()
		return name.split(".").slice(0, -1).join(".");
	function set_baseName(value : String)
	{
		var ext = extension;
		name = value + (ext == "" ? "" : "." + ext);
		return value;
	}

	override function init()
	{
		isFile = true;
		isDirectory = false;
		isRoot = false;
	}

	override public function toString()
		return null == parent ? name : parent.toString() + (parent.isRoot ? "" : "/") + escape(name);
}