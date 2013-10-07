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

class PrecogConfig 
{
	public var analyticsService(default, null) : String;
	public var apiKey(default, null) : String;
	public var accountId(default, null) : String;

	public function new(analyticsService : String, apiKey : String, accountId : String) 
	{
		setAnalyticsService(analyticsService);
		setAccountId(accountId);
		this.apiKey = apiKey;
	}

	function setAnalyticsService(service : String)
		analyticsService = service.rtrim("/");

	function setAccountId(accountId : String)
		this.accountId = accountId.rtrim("/");

		
//	public var email			: String;
//	public var password			: String;
}