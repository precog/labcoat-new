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
package precog.layout;

enum ExtentValue 
{
	Percent(value : Float);
	Absolute(value : Float);
}

abstract Extent(ExtentValue)
{
	public inline function new(v : ExtentValue)
	{
		this = v;
	}

	@:from public static inline function fromInt(v : Int)
	{
		return new Extent(ExtentValue.Absolute(v));
	}

	@:from public static inline function fromFloat(v : Float)
	{
		return new Extent(ExtentValue.Percent(v));
	}

	@:from public static inline function fromExtentValue(v : ExtentValue)
	{
		return new Extent(v);
	}

	public function isPercent() : Bool
	{
		return switch(this) {
			case Percent(_): true;
			case _: false;
		}
	}

	public function isAbsolute() : Bool
	{
		return switch(this) {
			case Absolute(_): true;
			case _: false;
		}
	}

	public function isAuto() : Bool
	{
		return switch(this) {
			case Percent(_): true;
			case _: false;
		}
	}

	public function value() : Float
	{
		return switch(this) {
			case Percent(v) | Absolute(v) : v;
		}
	}

	public function relativeTo(reference : Float)
	{
		return switch (this) {
			case Absolute(v): v;
			case Percent(v): reference * v;
		}
	}
}