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
import utest.Assert;
import precog.geom.IPoint;
import precog.geom.IRectangle;
import precog.geom.Point;
import precog.geom.Rectangle;

class AssertPoints 
{
	public static function assertEquals(test : IPoint, expected : IPoint, ?info : haxe.PosInfos)
	{
		Assert.isTrue(test.equals(expected), 'expected $expected but was $test', info);
	}
}

class AssertPoints2
{
	public static function assertEquals(test : IPoint, x : Float, y : Float, ?info : haxe.PosInfos)
	{
		AssertPoints.assertEquals(test, new Point(x,y), info);
	}
}

class AssertRectangles 
{
	public static function assertEquals(test : IRectangle, expected : IRectangle, ?info : haxe.PosInfos)
	{
		Assert.isTrue(test.equals(expected), 'expected $expected but was $test', info);
	}
}

class AssertRectangles2
{
	public static function assertEquals(test : IRectangle, x : Float, y : Float, w : Float, h : Float, ?info : haxe.PosInfos)
	{
		AssertRectangles.assertEquals(test, new Rectangle(x,y,w,h), info);
	}
}