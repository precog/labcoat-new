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

import utest.Assert;
import precog.geom.Point;
import precog.geom.Rectangle;
using Asserts;

class TestWrapLayout 
{
	public function new() { }

	public function testHorizontal()
	{
		var layout = new WrapLayout(200, 20, false),
			p1 = new Panel(),
			p2 = new Panel(),
			p3 = new Panel();

		layout.defaultWidth  = 120;
		layout.defaultHeight = 50;
		layout.addPanel(p1);
		layout.addPanel(p2).setWidth(50).setHeight(200);
		layout.addPanel(p3);
		layout.update();

		p1.rectangle.assertEquals(0,0,120,50);
		p2.rectangle.assertEquals(120,0,50,200);
		p3.rectangle.assertEquals(0,200,120,50);

		layout.boundaries.assertEquals(0, 0, 170, 250);
	}

	public function testVertical()
	{
		var layout = new WrapLayout(200, 100, true),
			p1 = new Panel(),
			p2 = new Panel(),
			p3 = new Panel();

		layout.defaultWidth  = 30;
		layout.defaultHeight = 30;
		layout.addPanel(p1);
		layout.addPanel(p2).setWidth(100).setHeight(40);
		layout.addPanel(p3);
		layout.update();

		p1.rectangle.assertEquals(0,0,30,30);
		p2.rectangle.assertEquals(0,30,100,40);
		p3.rectangle.assertEquals(0,70,30,30);

		layout.boundaries.assertEquals(0, 0, 100, 100);
	}

	public function testMargin()
	{
		var layout = new WrapLayout(200, 20, false),
			p1 = new Panel(),
			p2 = new Panel(),
			p3 = new Panel();

		layout.defaultWidth  = 120;
		layout.defaultHeight = 50;
		layout.addPanel(p1).setMarginWidth(10).setMarginHeight(20);
		layout.addPanel(p2).setWidth(50).setHeight(200).setMarginHeight(5);
		layout.addPanel(p3).setMarginWidth(20).setMarginHeight(10);
		layout.update();

		p1.rectangle.assertEquals(0,0,120,50);
		p2.rectangle.assertEquals(130,0,50,200);
		p3.rectangle.assertEquals(0,205,120,50);

		layout.boundaries.assertEquals(0, 0, 180, 255);
	}
}