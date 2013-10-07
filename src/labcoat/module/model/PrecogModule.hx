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

import precog.communicator.*;
import thx.react.Promise;
import precog.api.*;
import precog.api.Precog;
import labcoat.message.*;
import labcoat.message.PrecogRequest;
import labcoat.message.PrecogResponse;
using thx.core.Strings;
using StringTools;

class PrecogModule extends Module
{
	var apis : Map<String, Precog>;
	var configs : Map<String, PrecogConfig>;
	public function new()
	{
		super();
		apis = new Map();
		configs = new Map();
	}

	function setConfig(cont : PrecogNamedConfig)
	{
		if(configs.exists(cont.name))
			throw 'a precog config for ${cont.name} already exists';
		configs.set(cont.name, cont.config);
		apis.set(cont.name, new Precog({
				analyticsService : cont.config.analyticsService,
				apiKey : cont.config.apiKey
			})
		);
	}

	function normalizeDirectory(path : String)
	{
		var segments = path.split('/')
						.filter(function(v) return null != v)
						.map(Strings.trim.bind(_, "/"))
						.filter(function(v) return v != "");
		return segments.length == 0 ? '' : '${segments.join("/")}/';
	}

	function normalizeFilePath(path : String)
	{
		var segments = path.split('/')
						.filter(function(v) return null != v)
						.map(Strings.trim.bind(_, "/"))
						.filter(function(v) return v != "");
		return segments.length == 0 ? '' : '${segments.join("/")}';
	}

	override function connect(communicator : Communicator)
	{
		communicator.consume(function(configs : Array<PrecogNamedConfig>) {
			configs.map(setConfig);
		});
		
		communicator.on(function(request : PrecogRequest) {
			communicator.trigger(new Log("request: " + request.description));		
		});
		
		communicator.on(function(response : PrecogResponse) {
			communicator.trigger(new Log("response: " + response.description));		
		});

		function errorResponse(request : PrecogRequest, deferred : Deferred<Dynamic>) {
			return function(err) {
				var response = new ResponseError(err, request);
				deferred.reject(response);
				communicator.trigger(response);
				communicator.queue(new StatusMessage(err));
			};
		}

		communicator.respond(
			function(request : RequestMetadataChildren) : Null<Promise<ResponseMetadataChildren -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeDirectory(request.path);
				api.listChildren(path).then(
					function(result : Array<FileDescription>) {
						// load metadata file if available
						Promise.list(
							result
								.map(function(o) {
									return switch(o.type)
									{
										case "file":
											Promise.value({
												type : o.type,
												name : o.name,
												metadata : new Map<String, Dynamic>()
											});
										case "directory":
											var metafile = normalizeFilePath(request.path + o.name + "/metadata.json");
											var deferred = new Deferred();
											api.getFile(metafile).then(function(result : ResFile) {
													var metadata = new Map<String, Dynamic>();
													var contents = haxe.Json.parse(result.contents)[0];
													if(contents != null)
													{
														for(field in Reflect.fields(contents)) {
															metadata.set(field, Reflect.field(contents, field));
														}
													}
													deferred.resolve({
														type : o.type,
														name : o.name,
														metadata : metadata
													});
												},
												errorResponse(request, deferred)
											);	
											deferred.promise;
										case invalid:
											throw 'invalid type "$invalid"';
									};
								})
							)
							.then(function(arr : Array<{ type : String, name : String, metadata : Map<String, Dynamic> }>) {
									var response = new ResponseMetadataChildren(request.path, arr, request);
									deferred.resolve(response);
									communicator.trigger(response);
								},
								errorResponse(request, deferred)
							);

					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestMetadataChildren,
			ResponseMetadataChildren
		);

		communicator.respond(
			function(request : RequestFileGet) : Null<Promise<ResponseFileGet -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeFilePath(request.path);
				api.getFile(path).then(
					function(result) {
						var response = new ResponseFileGet(request.path, result, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileGet,
			ResponseFileGet
		);

		communicator.respond(
			function(request : RequestFileDelete) : Null<Promise<ResponseFileDelete -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeFilePath(request.path);
				api.delete0(path).then(
					function(result) {
						var response = new ResponseFileDelete(request.path, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileDelete,
			ResponseFileDelete
		);

		communicator.respond(
			function(request : RequestFileCreate) : Null<Promise<ResponseFileCreate -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeFilePath(request.path);
				api.createFile({
						type : request.type,
						path : path,
						contents : request.contents
					}).then(
					function(result) {
						var response = new ResponseFileCreate(request.path, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileCreate,
			ResponseFileCreate
		);

		communicator.respond(
			function(request : RequestFileUpload) : Null<Promise<ResponseFileUpload -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeFilePath(request.path);
				api.uploadFile({
						type : request.type,
						path : path,
						contents : request.contents
					}).then(
					function(result) {
						var response = new ResponseFileUpload(request.path, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileUpload,
			ResponseFileUpload
		);

		communicator.respond(
			function(request : RequestFileMove) : Null<Promise<ResponseFileMove -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				api.moveFile({
						source : request.src,
						dest   : request.dst
					}).then(
					function() {
						var response = new ResponseFileMove(request.src, request.dst, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileMove,
			ResponseFileMove
		);

		communicator.respond(
			function(request : RequestFileExecute) : Null<Promise<ResponseFileExecute -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var info : OptExecuteFile = { path : normalizeFilePath(request.path) };
				if(null != request.maxAge)
					info.maxAge = request.maxAge;
				if(null != request.maxStale)
					info.maxStale = request.maxStale;
				api.executeFile(info).then(
					function(result) {
						var response = new ResponseFileExecute(request.path, result, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileExecute,
			ResponseFileExecute
		);

		communicator.respond(
			function(request : RequestDirectoryDelete) : Null<Promise<ResponseDirectoryDelete -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var path = normalizeFilePath(request.path);
				api.deleteAll(path).then(
					function(result) {
						var response = new ResponseDirectoryDelete(request.path, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestDirectoryDelete,
			ResponseDirectoryDelete
		);

		communicator.respond(
			function(request : RequestDirectoryMove) : Null<Promise<ResponseDirectoryMove -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				api.moveDirectory({
						source : normalizeDirectory(request.src),
						dest   : normalizeDirectory(request.dst)
					}).then(
					function() {
						var response = new ResponseDirectoryMove(request.src, request.dst, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestDirectoryMove,
			ResponseDirectoryMove
		);

		communicator.respond(
			function(request : RequestFileMove) : Null<Promise<ResponseFileMove -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				api.moveFile({
						source : normalizeFilePath(request.src),
						dest   : normalizeFilePath(request.dst)
					}).then(
					function() {
						var response = new ResponseFileMove(request.src, request.dst, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileMove,
			ResponseFileMove
		);

		communicator.respond(
			function(request : RequestFileExist) : Null<Promise<ResponseFileExist -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				api.existsFile(request.path).then(
					function(exist : Bool) {
						var response = new ResponseFileExist(request.path, exist, request);
						deferred.resolve(response);
						communicator.trigger(response);
					},
					errorResponse(request, deferred)
				);
				return deferred.promise;
			},
			RequestFileExist,
			ResponseFileExist
		);

		communicator.respond(
			function(request : RequestDirectoryExist) : Null<Promise<ResponseDirectoryExist -> Void>> {
				var deferred = new Deferred(),
					api      = getApi(request.api);
				communicator.trigger(request);
				var parent = request.path.split("/").slice(0, -1).join("/"),
					name   = request.path.split("/").pop();
				api.listChildren(parent).then(
					function(result : Array<FileDescription>) {
						var exist = result.filter(function(des : FileDescription) return des.type == "directory" && des.name == name).length > 0;
						var response = new ResponseDirectoryExist(request.path, exist, request);
						deferred.resolve(response);
					}
				);
				return deferred.promise;
			},
			RequestDirectoryExist,
			ResponseDirectoryExist
		);
	}

	function getApi(name : String)
	{
		var api = apis.get(name);
		if(null == api)
			throw 'no api is set for $name';
		return api;
	}
}