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
package precog.fs;

using thx.core.Strings;

abstract Segment(ESegment)
{
	public function new(v : ESegment)
		this = v;

	static var PATTERN = ~/^[|](.+?)[|](i?)$/;
	@:from public static inline function fromESegment(segment : ESegment)
		return new Segment(segment);
	@:from public static function fromString(s : String)
	{
		return switch (s) {
			case "..":
				new Segment(Up);
			case ".":
				new Segment(Current);
			case pattern if(PATTERN.match(pattern)):
				new Segment(Pattern(PATTERN.matched(1), PATTERN.matched(2)));
			case v:
				new Segment(Literal(v.trim("/")));
		}
	}

	public inline function getESegment() : ESegment
	{
		return this;
	}

	public function getLiteral()
	{
		switch (this) {
			case Literal(v): return v;
			case _: throw "expected a literal segment value";
		}
	}

	public inline function toString()
	{
		return switch (this) {
			case Literal(s):	s;
			case Pattern(p, m):	'|$p|$m';
			case Up:			"..";
			case Current:		".";
		}
	}
}
