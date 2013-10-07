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

@:access(precog.fs.Nodes)
class Directory extends Node
{
	public var directories(default, null) : Directories;
	public var files(default, null) : Files;

	public var length(default, null) : Int;

	public function new(name : String, parent : Directory, ?meta : Map<String, Dynamic>)
	{
		super(name, parent, meta);
		files = new Files(this);
		directories = new Directories(this);
		length = 0;
	}

	override function init()
	{
		isFile = false;
		isDirectory = true;
		isRoot = false;
	}

	override function remove()
	{
		if(length > 0)
			throw "directory is not empty and cannot be removed";
		super.remove();
	}

	public function removeRecursive()
	{
		for(file in files)
			file.remove();
		for(directory in directories)
			directory.removeRecursive();
		remove();
	}

	public function addNode(node : Node)
	{
		if(node.isRoot) throw "root node cannot be added or removed";
		node.remove();
		var match = ESegment.Literal(node.name);
		if(node.isDirectory && directories.find(match).length > 0)
			throw 'a directory with the same name already exist: ${node.name}';
		if(node.isFile && files.find(match).length > 0)
			throw 'a file with the same name already exist: ${node.name}';
		node.parent = this;
		node.filesystem = this.filesystem;
		length++;
		if(node.isFile)
			files.add(cast node);
		else if(node.isDirectory)
			directories.add(cast node);
		trigger(new NodeAddEvent(node));
	}

	public function removeNode(node : Node)
	{
		if(node.isRoot) throw "root node cannot be added or removed";
		if((node.isFile && files.remove(cast node)) || (node.isDirectory && directories.remove(cast node))) {
			length--;
			return true;
		} else {
			return false;
		}
	}

	public function nodes() : Array<Node>
	{
		return cast files.list().concat(cast directories.list());
	}

	public function find(segment : Segment) : Array<Node>
	{
		return cast files.find(segment).concat(cast directories.find(segment));
	}

	public function pick(path : Path) : Node
	{
		return traverse(path)[0];
	}

	public function exists(path : Path)
	{
		return null != pick(path);
	}

	public function existsFile(path : Path)
	{
		var ls = traverse(path);
		for(node in ls)
			if(node.isFile)
				return true;
		return false;
	}

	public function existsDirectory(path : Path)
	{
		var ls = traverse(path);
		for(node in ls)
			if(node.isDirectory)
				return true;
		return false;
	}

	public function traverse(path : Path) : Array<Node>
	{
		var dirs = [path.absolute() ? filesystem.root : this],
			segments = path.segments().copy();
		if(segments.length == 0)
			return cast dirs;
		var last = segments.pop(),
			results : Array<Node> = [];
		dirs = traverseImpl(dirs, segments);
		for(dir in dirs)
			results = results.concat(cast dir.directories.find(last)).concat(cast dir.files.find(last));
		return results;
	}

	public function walk(path : Path, handler : Node -> Void)
	{
		if(path.length == 0)
			return;
		path = path.copy();
		var fpath = path.shift(),
			first = pick(fpath);
		if(null == first) return;
		handler(first);
		if(first.isDirectory)
			cast(first, Directory).walk(path, handler);
//		var segment = path
	}

	function traverseImpl(dirs : Array<Directory>, segments : Array<Segment>)
	{
		if(segments.length == 0 || dirs.length == 0)
			return dirs;
		var segment = segments.shift();
		var results = [];
		for(dir in dirs)
			results = results.concat(dir.directories.find(segment));
		return traverseImpl(results, segments);
	}

	public function removeAt(path : Path, ?recursive : Bool = false)
	{
		var list = traverse(path),
			dir : Directory;
		for(item in list)
		{
			if(recursive && item.isDirectory)
			{
				dir = cast item;
				dir.removeRecursive();
			}
			else
				item.remove();
		}
	}

	public function createFileAt(path : Path, ?autoCreateDirectories : Bool = false, ?meta : Map<String, Dynamic>) : File
	{
		var name = path.segments().pop().getLiteral();
		var dir : Directory = null;
		if(autoCreateDirectories)
			dir = this.ensureDirectory(path)
		else
			dir = cast traverse(path)[0];
		if(dir == null)
			throw "destination directory doesn't exist for " + path;
		return new File(name, dir, meta);
	}

	public function ensureDirectory(path : Path, ?meta : Map<String, Dynamic>) : Directory
	{
		var dir = path.absolute() ? filesystem.root : this,
			segments = path.segments();
		while(segments.length > 0)
		{
			var segment = segments[0],
				next = dir.directories.pick(segment);
			if(null == next)
				break;
			segments.shift();
			dir = next;
		}
		while(segments.length > 0)
			dir = new Directory(segments.shift().getLiteral(), dir, meta);
		return dir;
	}

	macro override function trigger<T>(ethis : haxe.macro.Expr, values : Array<haxe.macro.Expr>)
	{
		return macro { if(null != $ethis.filesystem) $ethis.filesystem.dispatcher.trigger($a{values}); };
	}

	override public function toString()
		return (null == parent ? escape(name) : parent.toString() + (parent.isRoot ? "" : "/") + escape(name));
}