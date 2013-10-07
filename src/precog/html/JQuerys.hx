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
package precog.html;

import jQuery.JQuery;

class JQuerys 
{
	static var DBLCLICK_DELAY : Int = 300;
	public static function getInnerSize(o : JQuery)
	{
		return {
			width  : o.innerWidth(),
			height : o.innerHeight()
		};
	}

	public static function getOuterSize(o : JQuery)
	{
		return {
			width  : o.outerWidth(),
			height : o.outerHeight()
		};
	}

	public static function cssTransform(o : JQuery, transform : String)
	{
		o.css("-webkit-transform", transform)
		 .css("-moz-transform", transform)
		 .css("-ms-transform", transform)
		 .css("-o-transform", transform)
		 .css("transform", transform);
	}

	public static function clickOrDblClick(o : JQuery, click : Dynamic, dblclick : Dynamic)
	{
		var timer = null,
			count = 0;
		
		o.click(function(e) {
			if(null == timer)
			{
				Reflect.callMethod(o, click, [e]);
				count = 0;
				timer = haxe.Timer.delay(function() {
					timer = null;
					if(count > 1)
						Reflect.callMethod(o, dblclick, [e]);
				}, DBLCLICK_DELAY);
			}
			count++;
		});
	}

	static function __init__() 
	{
#if embed_jquery
		haxe.macro.Compiler.includeFile("precog/html/jquery-1.9.1.js");
#end
	}
}