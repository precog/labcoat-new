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
package labcoat.module.model;

import labcoat.message.*;
import precog.communicator.*;
import thx.react.Promise;

class PrecogAuthModule extends Module
{
	static var CREDENTIALS_KEY = "labcoat2-credentials";
	var store : js.html.Storage;
	var obfuscator : Obfuscator;
	public function new()
	{
		super();
		store = js.Browser.window.sessionStorage;
		obfuscator = new Obfuscator();
	}

	override function connect(communicator : Communicator)
	{
		// TODO
		// load credentials from sessionStorage
		var credentials = loadCredentials();
		if(null == credentials)
			communicator.provide(new RequestPrecogCredentials());
		else
			communicator.queueMany(credentials);
		communicator.consume(function(data : Array<PrecogNamedConfig>) {
			storeCredentials(data);
		});
		communicator.on(function(_ : Logout) {
			clearCredentials();
		});
	}

	function clearCredentials()
	{
		store.removeItem(CREDENTIALS_KEY);
	}

	function storeCredentials(data : Array<PrecogNamedConfig>)
	{
		store.setItem(CREDENTIALS_KEY, encode(data));
	}

	function loadCredentials() : Array<PrecogNamedConfig>
	{
		var s = store.getItem(CREDENTIALS_KEY);
		if(null == s)
			return null;
		else
			return decode(s);
	}

	function encode(a : Array<PrecogNamedConfig>)
	{
		return obfuscator.encode(haxe.Json.stringify(a.map(function(item) {
			return {
				name : item.name,
				analyticsService : item.config.analyticsService,
				apiKey : item.config.apiKey,
				accountId : item.config.accountId
			};
		})));
	}

	function decode(s : String) : Array<PrecogNamedConfig>
	{
		try {
			var obs : Array<ConfigInfo> = haxe.Json.parse(obfuscator.decode(s));
			return obs.map(function(ob) {
				var config = new PrecogConfig(ob.analyticsService, ob.apiKey, ob.accountId);
				return new PrecogNamedConfig(ob.name, config);
			});
		} catch(e : Dynamic) {
			return null;
		}
	}
}

class Obfuscator
{
	var base : haxe.crypto.BaseCode;
	public function new() {
		base = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789+=/*")); // 
	}
	public function encode(s : String)
	{
		return base.encodeString(s);
	}

	public function decode(s : String)
	{
		return base.decodeString(s);
	}
}

typedef ConfigInfo =
{
	name : String,
	analyticsService : String,
	apiKey : String,
	accountId : String
}