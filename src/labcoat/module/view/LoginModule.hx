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
package labcoat.module.view;

import labcoat.message.*;
import precog.communicator.*;
import precog.api.Precog;
import precog.html.LabcoatAccountWindow;

class LoginModule extends Module
{
	static var SERVICES = ['https://nebula.precog.com','https://beta.precog.com'];
	static var DEFAULT_SERVICE = 'https://beta.precog.com';
	var communicator : Communicator;

	override public function connect(communicator : Communicator)
	{
		this.communicator = communicator;
		communicator.demand(RequestPrecogCredentials).then(function(_ : RequestPrecogCredentials) {
			displayForm();
		});
	}

	function findServiceAndAccount(email : String, handler : Null<{ analyticsService : String, accountId : String }> -> Void)
	{
		var services = SERVICES.copy();
		function tryService() {
			if(services.length == 0)
			{
				handler(null);
				return;
			}
			var service = services.shift();
			var api = new Precog({ analyticsService : service });
			api.lookupAccountId(email)
				.then(
					function(result : precog.api.ResAccountId) {
						handler({ analyticsService : service, accountId : result.accountId });
					},
					function(e : Dynamic) {
						tryService();
					});
		}

		tryService();
	}

	function login(service : String, email : String, password : String, callback : Validation -> Void)
	{
		var api = new Precog({ analyticsService : service });
		api.describeAccount({ email : email, password : password })
			.then(
				function(result : ResDescribeAccount) {
					callback(Ok);
					var config = new PrecogConfig(service, result.apiKey, result.accountId);
					communicator.queue(new PrecogNamedConfig("default", config));
				},
				function (error){
					callback(Error("login error: " + Std.string(error)));
				} 
			);
	}

	function processCreate(data : { email : String, password : String, profile : { name : String, company : String, title : String }}, handler : Validation -> Void)
	{
		findServiceAndAccount(data.email, function(info) {
			if(null == info) {
				var api = new Precog({ analyticsService : DEFAULT_SERVICE });
				api.createAccount(data)
					.then(
						function(result : precog.api.ResAccountId) {
							login(DEFAULT_SERVICE, data.email, data.password, handler);
						},
						function(e : Dynamic) {
							handler(Error('an error occurred creating the account: ' + Std.string(e)));
						}
					);
			} else {
				handler(Error('an account for this email already exists on ${info.analyticsService}'));
			}
		});
	}

	function processLogin(data : { email : String, password : String }, handler : Validation -> Void)
	{
		findServiceAndAccount(data.email, function(info) {
			if(null != info) {
				login(info.analyticsService, data.email, data.password, handler);
			} else {
				handler(Error("this email doesn't seem to have an associated account"));
			}
		});
	}

	function processReset(data : { email : String}, handler : Validation -> Void)
	{
		findServiceAndAccount(data.email, function(info) {
			if(null != info) {
				var api = new Precog({ analyticsService : info.analyticsService });
				api.requestPasswordReset(data.email)
					.then(
						function(r) {
							handler(Ok);
						},
						function(e) {
							handler(Error("an error occurred resetting the password: " + Std.string(e)));
						}
					);
			} else {
				handler(Error("this email doesn't seem to have an associated account"));
			}
		});
	}

	function displayForm() {
		new jQuery.JQuery(function() {
			var dialog = new LabcoatAccountWindow();
			dialog.processCreate = processCreate;
			dialog.processLogin = processLogin;
			dialog.processReset = processReset;
			dialog.show();
		});
	}
}