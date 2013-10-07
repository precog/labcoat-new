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
package precog.geom;

import thx.react.Suspendable;

class Point extends Suspendable<IPoint> implements IPointObservable
{
	public var x(default, null) : Float;
	public var y(default, null) : Float;
	public function new(x = 0.0, y = 0.0)
	{
		this.x = x;
		this.y = y;
	}

	public function equals(other : IPoint)
		return x == other.x && y == other.y;

	public function toString()
		return 'Point($x, $y)';
		
	public function set(x : Float, y : Float)
	{
		if(this.x == x && this.y == y) return;
		this.x = x;
		this.y = y;
		notify(true);
	}
}