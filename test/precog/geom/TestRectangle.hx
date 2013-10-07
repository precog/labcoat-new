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

using Asserts;
using precog.geom.Rectangle;
using precog.geom.IRectangle;
using thx.react.IObservable;
import utest.Assert;

class TestRectangle 
{
	public function new() { }

	public function testValues()
	{
		var rect = new Rectangle(1, 2, 3, 4);
		Assert.equals(1, rect.x);
		Assert.equals(2, rect.y);
		Assert.equals(3, rect.width);
		Assert.equals(4, rect.height);
	}

	public function testObservable()
	{
		var x = 0.0,
			y = 0.0,
			width = 0.0,
			height = 0.0,
			rect = new Rectangle(0, 0, 0, 0);
		rect.addListener(function(rect : IRectangle) {
			x = rect.x;
			y = rect.y;
			width = rect.width;
			height = rect.height;
		});
		rect.set(1, 2, 3, 4);
		Assert.equals(1, x);
		Assert.equals(2, y);
		Assert.equals(3, width);
		Assert.equals(4, height);
	}

	public function testEquals()
	{
		Assert.isTrue(new Rectangle(1, 2, 3, 4).equals(new Rectangle(1, 2, 3, 4)));
	}

	public function testAddRectangle()
	{
		new Rectangle(-10, -5, 20, 10)
			.addRectangle(new Rectangle(-30, 15, 20, 10))
			.assertEquals(-30, -5, 40, 30);

		new Rectangle(-10, -5, 20, 100)
			.addRectangle(new Rectangle(30, 15, 20, 10))
			.assertEquals(-10, -5, 60, 100);
	}
}