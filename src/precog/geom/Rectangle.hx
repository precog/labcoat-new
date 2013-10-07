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

@:access(precog.geom.Point)
class Rectangle extends Suspendable<IRectangle> implements IRectangleObservable
{
	public var x(default, null) : Float;
	public var y(default, null) : Float;
	public var width(default, null) : Float;
	public var height(default, null) : Float;
	public function new(x = 0.0, y = 0.0, width = 0.0, height = 0.0)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function clone()
		return new Rectangle(x, y, width, height);

	public function equals(other : IRectangle)
		return 
			x == other.x && y == other.y
			&&
			width == other.width && height == other.height;

	public function toString()
		return 'Rectangle($x, $y, $width, $height)';

		
	public function set(x : Float, y : Float, width : Float, height : Float)
	{
		if(this.x == x && this.y == y
			&&
			this.width == width && this.height == height) return;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		notify(true);
	}

	public function update(other : IRectangle)
	{
		set(other.x, other.y, other.width, other.height);
	}

	public function updateSize(other : IRectangle)
	{
		set(x, y, other.width, other.height);
	}

	public function addRectangle(other : IRectangle)
	{
		wrapSuspended(function() {
 			addPointXY(other.x, other.y);
			addPointXY(other.x + other.width, other.y + other.height);
		});
		return this;
	}

	public inline function addPoint(point : IPoint)
	{
		return addPointXY(point.x, point.y);
	}

	public function addPointXY(px : Float, py : Float)
	{
		var x = this.x,
			y = this.y,
			w = this.width,
			h = this.height;
		if(px < this.x) {
			x = px;
			w = this.x + this.width - x;
		} else if(px > this.x + this.width) {
			w = px - this.x;
		}
		if(py < this.y) {
			y = py;
			h = this.y + this.height - y;
		} else if(py > this.y + this.height) {
			h = py - this.y;
		}
		set(x, y, w, h);
		return this;
	}
/*
	var points : Array<Point>
	function getPoint(index)
	{
		if(null == points)
			points = [];
		var point = points[index];
		if(null == point)
		{
			points[index] = point = new Point(); // TODO
			var applyRect  = null,
				applyPoint = null;
			switch (index) {
				case 0: //TL
					applyRect  = function(r) point.setXY(r.x, r.y);
					applyPoint = function(p) this.set(p.x, p.y, this.width, this.height);
			}
			applRecty(this);
			addListener(applyRect);
			point.addListener(applyPoint);
		}
		return point;
	}
*/
}