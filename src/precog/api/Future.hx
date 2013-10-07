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
package precog.api;

extern class Future<TAccept, TFailure>
{
	public function then(onaccept : TAccept, ?onreject : TFailure) : Future<TAccept, TFailure>;

	public function done(onaccept : TAccept, ?onreject : TFailure) : Void;
	inline public static function catchError<TFailure, TNAccept, TNFailure>(onreject : TFailure) : Future<TNAccept, TNFailure>
		return untyped precog.api.Future["catch"](onreject);

	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic, v4 : Dynamic, v5 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic, v4 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic) : Future<TAccept, TFailure> {})
	public static function any<TFailure>() : Future<Void -> Void, TFailure>;

	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic, v4 : Dynamic, v5 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic, v4 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic, v3 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic, v2 : Dynamic) : Future<TAccept, TFailure> {})
	@:overload(function<TAccept, TFailure>(v1 : Dynamic) : Future<TAccept, TFailure> {})
	public static function every<TFailure>() : Future<Void -> Void, TFailure>;

	static function __init__() : Void
	{
		var api = untyped __js__('(precog || (precog = {})) && (precog.api || (precog.api = {}))');
		if(untyped window)
			api.Future = untyped window.Future;
		else
			api.Future = untyped require("Future");
	}
}