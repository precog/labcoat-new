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
package precog.util;

using thx.react.promise.Http;
using thx.react.Promise;
import thx.culture.Culture;
import thx.translation.Translation;
import haxe.Json;

class Assets 
{
	public static function json(path : String) : Promise<Dynamic -> Void>
	{
		// TODO replace HTTP for FS when available (NodeJS, Cordova)
		return new Http(path).request().pipe(function(s : String) {
			return Promise.value(Json.parse(s));
		});
	}

	public static function localization(name : String) : Promise<Culture -> Translation -> Void>
	{
		if(name == "en-US") // no translation required
		{
			var culture = Culture.invariant,
				translation = new Translation(culture);
			return Promise.value2(culture, translation);
		} else {
			return
				json('localization/$name.json')
				.await(json('translation/$name.json'))
				.pipe(function(ob_culture : Dynamic, ob_translation : Dynamic) : Promise<Culture -> Translation -> Void> {
					var culture = Culture.createFromObject(ob_culture),
						translation = new Translation(culture);
					translation.addPo2JsonObject(ob_translation);
					return Promise.value2(culture, translation);
				});
		}
	}
}