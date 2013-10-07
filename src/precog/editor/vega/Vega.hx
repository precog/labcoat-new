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
package precog.editor.vega;

@:native("vg") extern class Vega 
{
	public static var parse(default, null) : {
		@:overload(function(spec : {}, handler : VegaConstructor -> Void) : Void {})
		public function spec(spec : String, handler : VegaConstructor -> Void) : Void;
	};

	static function __init__() : Void
    {
    	haxe.macro.Compiler.includeFile("precog/editor/vega/d3.js");
        haxe.macro.Compiler.includeFile("precog/editor/vega/vega.js");
    }
}

typedef VegaConstructor = VegaParams -> VegaView;

typedef VegaParams = {
	el : Dynamic,
	?data : {},
	?hover : Bool,
	?renderer : String
}

extern class VegaView
{
	public function width(v : Int) : VegaView;
	public function height(v : Int) : VegaView;
	public function padding(v : {
		?top : Int,
		?bottom : Int,
		?left : Int,
		?right : Int,
	}) : VegaView;
	public function viewport(v : Array<Int>) : VegaView;
	public function renderer(v : String) : VegaView;
	// TODO add rest documented here: https://github.com/trifacta/vega/wiki/Runtime
	public function update() : VegaView;
}