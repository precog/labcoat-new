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

import thx.react.Responder;
import thx.react.Provider;
import thx.react.Promise;
import thx.react.Dispatcher;
import thx.react.Buffer;

#if macro
import haxe.macro.Expr;
#end

class Communicator
{
	@:noDoc @:noDisplay public var provider(default, null)   : Provider;
	@:noDoc @:noDisplay public var responder(default, null)  : Responder;
	@:noDoc @:noDisplay public var dispatcher(default, null) : Dispatcher;
	@:noDoc @:noDisplay public var buffer(default, null)     : Buffer;
	public function new()
	{
		provider   = new Provider();
		responder  = new Responder();
		dispatcher = new Dispatcher();
		buffer     = new Buffer();
	}

	macro public function on(ethis : ExprOf<Communicator>, handler : Expr)
	{
		return macro { $ethis.dispatcher.on($handler); $ethis; };
	}

	macro public function one<T>(ethis : ExprOf<Communicator>, handler : Expr)
	{
		return macro { $ethis.dispatcher.one($handler); $ethis; };
	}

	macro public function off<T>(ethis : ExprOf<Communicator>, handler : Expr)
	{
		return macro { $ethis.dispatcher.off($handler); $ethis; };
	}

	macro public function trigger<T>(ethis : ExprOf<Communicator>, values : Array<Expr>)
	{
		return macro { $ethis.dispatcher.trigger($a{values}); $ethis; };
	}

	public function clear(type : Class<Dynamic>)
	{
		if (null != type)
			dispatcher.clear(type);
	}

	public function demand<T>(type : Class<T>) : Promise<T -> Void>
	{
		return provider.demand(type);
	}
	
	public function provide<T>(data : T)
	{
		provider.provide(data);
		return this;
	}

	public function provideLazy<T>(type : Class<T>, handler : Deferred<T> -> Void)
	{
		provider.provideLazy(type, handler);
		return this;
	}

	public function request<TRequest, TResponse>(payload : TRequest, responseType : Class<TResponse>) : Promise<TResponse -> Void>
	{
		return responder.request(payload, responseType);
	}

	public function respond<TRequest, TResponse>(handler : TRequest -> Null<Promise<TResponse -> Void>>, requestType : Class<TRequest>, responseType : Class<TResponse>)
	{
		return responder.respond(handler, requestType, responseType);
	}

	public function queue<T>(value : T)
	{
		buffer.queueMany([value]);
	}

	public function queueMany<T>(values : Iterable<T>)
	{
		buffer.queueMany(values);
	}

	macro public function consume<T>(ethis : ExprOf<Communicator>, handler : Expr)
	{
		var name = Buffer.getArrayArgumentType(handler);
		return macro $ethis.buffer.consumeImpl($v{name}, $handler);
	}
}