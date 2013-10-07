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

class TestDockLayout 
{
	var layout : DockLayout;
	var panel : Panel;

	public function new() { }

	public function setup()
	{
		layout = new DockLayout(200, 100);
		panel  = new Panel();
	}

	public function testAddAdd() 
	{
		layout.addPanel(panel);
		layout.addPanel(panel).dockLeft(0.5);
		layout.update();
		panel.rectangle.assertEquals(0, 0, 100, 100);
	}

	public function testAddAddToOther() 
	{
		layout.addPanel(panel);
		layout.update();
		panel.rectangle.assertEquals(0, 0, 200, 100);
		var layout2 = new DockLayout(100, 50);
		layout2.addPanel(panel).dockLeft(0.5);
		layout.update();
		layout2.update();

		Assert.isFalse(layout.iterator().hasNext());

		panel.rectangle.assertEquals(0, 0, 50, 50);
	}

	public function testSimple()
	{
		layout.addPanel(panel).dockLeft(0.2);
		layout.update();

		panel.rectangle.assertEquals(0,0,40,100);
	}

	public function testComplex()
	{
		var p1 = new Panel(),
			p2 = new Panel(),
			p3 = new Panel(),
			p4 = new Panel(),
			p5 = new Panel();
		layout.addPanel(p1).dockLeft(0.2);
		layout.addPanel(p2).dockRight(40);
		layout.addPanel(p3).dockTop(20);
		layout.addPanel(p4).dockLeft(0.1);
		layout.addPanel(p5);
		layout.update();

		p1.rectangle.assertEquals(  0,  0,  40, 100);
		p2.rectangle.assertEquals(160,  0,  40, 100);
		p3.rectangle.assertEquals( 40,  0, 120,  20);
		p4.rectangle.assertEquals( 40, 20,  20,  80);
		p5.rectangle.assertEquals( 60, 20, 100,  80);
	}

	public function testFill()
	{
		layout.addPanel(panel);
		layout.update();
		panel.rectangle.assertEquals(0,0,200,100);
	}

	public function testFill2()
	{
		var panel2 = new Panel();
		layout.addPanel(panel);
		layout.addPanel(panel2);
		layout.update();
		panel.rectangle.assertEquals(0,0,100,100);
		panel2.rectangle.assertEquals(100,0,100,100);
	}

	public function testExceededBoundaries()
	{
		layout.update();
		Assert.isTrue(Math.isNaN(layout.boundaries.width));
		Assert.isTrue(Math.isNaN(layout.boundaries.height));

		var dock = layout.addPanel(panel);
		layout.update();
		layout.boundaries.assertEquals(0, 0, 200, 100);

		dock.dockLeft(50);
		layout.update();
		layout.boundaries.assertEquals(0, 0, 50, 100);
	}

	public function testMargin()
	{
		var p2 = new Panel(),
			p3 = new Panel(),
			p4 = new Panel();
		layout.addPanel(panel).dockLeft(50).setMargin(10);
		layout.addPanel(p2).dockTop(50).setMargin(0.1);
		layout.addPanel(p3).setMargin(0.1);
		layout.addPanel(p4).setMargin(0.1);
		layout.update();

		panel.rectangle.assertEquals(0,0,50,100);
		p2.rectangle.assertEquals(60,0,140,50);
		p3.rectangle.assertEquals(60,60,60,40);
		p4.rectangle.assertEquals(140,60,60,40);
		layout.boundaries.assertEquals(0, 0, 200, 100);
	}
}