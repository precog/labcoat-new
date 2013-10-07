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
import precog.layout.CanvasLayout;
import precog.layout.Extent;
using Asserts;

class TestCanvasLayout
{
	static var point0 = new Point(0, 0);
	var layout : CanvasLayout;
	var panel  : Panel;
	public function new() { }

	public function setup()
	{
		layout = new CanvasLayout(200, 100);
		panel  = new Panel();
	}

	public function testDefault()
	{
		layout.addPanel(panel);
		layout.update();
		panel.rectangle.assertEquals(0.0,0.0,0.0,0.0);
	}

	public function testAnchors()
	{
		var tests = [
				{
					layout : TopLeft, panel : TopLeft,
					expected : new Rectangle(0, 0, 80, 40)
				}, {
					layout : TopLeft, panel : Center,
					expected : new Rectangle(-40, -20, 80, 40)
				}, {
					layout : TopLeft, panel : BottomRight,
					expected : new Rectangle(-80, -40, 80, 40)
				}, {
					layout : Center, panel : TopLeft,
					expected : new Rectangle(100, 50, 80, 40)
				}, {
					layout : Center, panel : Center,
					expected : new Rectangle(60, 30, 80, 40)
				}, {
					layout : Center, panel : BottomRight,
					expected : new Rectangle(20, 10, 80, 40)
				}, {
					layout : BottomRight, panel : TopLeft,
					expected : new Rectangle(200, 100, 80, 40)
				}, {
					layout : BottomRight, panel : Center,
					expected : new Rectangle(160, 80, 80, 40)
				}, {
					layout : BottomRight, panel : BottomRight,
					expected : new Rectangle(120, 60, 80, 40)
				}, 
			];

		var canv = layout.addPanel(panel).setSize(80, 40);
		for(test in tests)
		{
			canv.setLayoutAnchor(test.layout)
				.setPanelAnchor(test.panel);
			layout.update();
			Assert.isTrue(
				panel.rectangle.equals(test.expected),
				'expected ${test.expected} but is ${panel.rectangle} for $test'
			);
		}

	}

	public function testOffset()
	{
		layout.addPanel(panel)
			.setPanelAnchor(Center)
			.setLayoutAnchor(Center)
			.setOffset(-10, 10)
			.setSize(20, 20);
		layout.update();
		var test = new Rectangle(90, 60, 20, 20);
		Assert.isTrue(
			panel.rectangle.equals(test),
			'expected ${test} but is ${panel.rectangle}'
		);
	}
	public function testSize()
	{
		layout.addPanel(panel)
			.setSize(100, 0.5);
		layout.update();
		var test = new Rectangle(0, 0, 100, 50);
		Assert.isTrue(
			panel.rectangle.equals(test),
			'expected $test but is ${panel.rectangle}'
		);
	}

	public function testBoundaries() 
	{
		layout.addPanel(panel)
			.setSize(10, 10)
			.setOffset(20, 20);
		layout.update();
		layout.boundaries.assertEquals(20.0,20.0,10.0,10.0);

		var panel2 = new Panel();
		layout.addPanel(panel2)
			.setSize(10, 10)
			.setOffset(50, 50);
		layout.update();
		layout.boundaries.assertEquals(20.0,20.0,40.0,40.0);
	}
}