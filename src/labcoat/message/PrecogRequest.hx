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
package labcoat.message;

using thx.core.Strings;

class PrecogRequest 
{
	public var uid(default, null) : String;
	public var api(default, null) : String;
	public var description(default, null) : String;
	public var time(default, null) : Date;
	function new(?api : String) 
	{
		this.uid = precog.util.Uid.create();
		this.api = null == api ? "default" : api;
		this.time = Date.now();
	}
}

class Helper
{
	public static function normalizepath(p : String)
	{
		return "/" + p.trim("/");
	}
	public static function normalizeDirectoryPath(p : String)
	{
		var p = "/" + p.trim("/") + "/";
		if(p == "//")
			return "/";
		else
			return p;
	}
}

class RequestMetadataChildren extends PrecogRequest
{
	public var path(default, null) : String;
	public function new(path : String, ?api : String)
	{
		super(api);
		this.path = Helper.normalizeDirectoryPath(path);
		this.description = 'metadata children at ${this.path}';
	}
}

class RequestFileBase extends PrecogRequest
{
	public var path(default, null) : String;
	public function new(path : String, ?api : String)
	{
		super(api);
		this.path = Helper.normalizepath(path);
		this.description = 'request ' + Type.getClassName(Type.getClass(this)).split(".").pop().substr(7).humanize() + ' for $path';
	}
}

class RequestFileGet extends RequestFileBase
{
	
}

class RequestFileExist extends RequestFileBase
{
	
}

class RequestDirectoryExist extends RequestFileBase
{
	
}

class RequestFileCreate extends RequestFileBase 
{
	public var type(default, null) : String;
	public var contents(default, null) : String;
	public function new(path : String, type : String, contents : String, ?api : String)
	{
		super(path, api);
		this.type = type;
		this.contents = contents;
	}
}

class RequestFileUpload extends RequestFileBase 
{
	public var type(default, null) : String;
	public var contents(default, null) : String;
	public function new(path : String, type : String, contents : String, ?api : String)
	{
		super(path, api);
		this.type = type;
		this.contents = contents;
	}
}

class RequestFileDelete extends RequestFileBase
{

}

class RequestFileExecute extends RequestFileBase 
{
	public var maxAge(default, null) : Null<Float>;
	public var maxStale(default, null) : Null<Float>;
	public function new(path : String, ?maxage : Float, ?maxstale : Float, ?api : String)
	{
		super(path, api);
		this.maxAge = maxage;
		this.maxStale = maxstale;
	}

}

class RequestDirectoryDelete extends RequestFileBase
{

}

class RequestDirectoryMove extends PrecogRequest 
{
	public var src(default, null) : String;
	public var dst(default, null) : String;
	public function new(src : String, dst : String, ?api : String)
	{
		super(api);
		this.src = Helper.normalizeDirectoryPath(src);
		this.dst = Helper.normalizeDirectoryPath(dst);
		this.description = 'move directory from ${this.src} to ${this.dst}';
	}
}

class RequestFileMove extends PrecogRequest 
{
	public var src(default, null) : String;
	public var dst(default, null) : String;
	public function new(src : String, dst : String, ?api : String)
	{
		super(api);
		this.src = Helper.normalizepath(src);
		this.dst = Helper.normalizepath(dst);
		this.description = 'move file from ${this.src} to ${this.dst}';
	}
}