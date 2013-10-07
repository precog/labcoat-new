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

using thx.react.IObservable;
using precog.geom.Rectangle;
using precog.layout.Extent;

@:access(precog.geom.Point)
class DockLayout extends Layout
{
	var docks : Map<Panel, Dock>;
	public var defaultDock : DockKind;
	public var defaultMargin : Extent;
	public function new(width : Float, height : Float)
	{
		super(width, height);
		defaultDock = Fill;
		defaultMargin = 0;
		docks = new Map();
		onpanel.remove.addListener(function(panel) {
			docks.remove(panel);
		});
	}

	public function addPanel(panel : Panel) : Dock
	{
		panels.addPanel(panel);
		var dock = new Dock(defaultDock, defaultMargin);
		docks.set(panel, dock);
		return dock;
	}

	override function createUpdateQueue()
	{
		return [beforeUpdate, panelIteratorFunction(measurePanel), afterMeasure, panelIteratorFunction(updatePanel), afterUpdate];
	}

	var available : Rectangle;
	var fillqueue : Array<Panel>;

	function beforeUpdate() 
	{
		available = new Rectangle(0, 0, 0, 0);
		fillqueue = [];
	}

	function measurePanel(panel : Panel)
	{
		var dock = docks.get(panel);
		if(null == dock)
			trace('dock null for $panel');
		switch(dock.dock)
		{
			case Top(esize), Bottom(esize):
				var fl = esize.relativeTo(rectangle.height),
					mg = dock.margin.relativeTo(rectangle.height);
				available.set(rectangle.x, rectangle.y, available.width, available.height + fl + mg);
			case Right(esize), Left(esize):
				var fl = esize.relativeTo(rectangle.width),
					mg = dock.margin.relativeTo(rectangle.width);
				available.set(rectangle.x, rectangle.y, available.width + fl + mg, available.height);
			case Fill:
				fillqueue.push(panel);
		}
	}

	function afterMeasure() 
	{
		var w = available.width > rectangle.width ? available.width : rectangle.width,
			h = available.height > rectangle.height ? available.height : rectangle.height;
		if(fillqueue.length > 0)
		{
			measuredBoundaries.set(rectangle.x, rectangle.y, w, h);
		} else if(available.width > 0 || available.height > 0) {
			measuredBoundaries.set(rectangle.x, rectangle.y, 
				available.width == 0 ? rectangle.width : available.width,
				available.height == 0 ? rectangle.height : available.height);
		}
		available.set(rectangle.x, rectangle.y, w, h);
	}

	override function updatePanel(panel : Panel)
	{
		var dock = docks.get(panel);
		switch(dock.dock)
		{
			case Top(esize):
				var fl = esize.relativeTo(rectangle.height),
					mg = dock.margin.relativeTo(rectangle.height);
				panel.rectangle.set(available.x, available.y, available.width, fl);
				available.set(available.x, available.y + fl + mg, available.width, available.height - fl - mg);
			case Right(esize):
				var fl = esize.relativeTo(rectangle.width),
					mg = dock.margin.relativeTo(rectangle.width);
				panel.rectangle.set(available.x + available.width - fl, available.y, fl, available.height);
				available.set(available.x, available.y, available.width - fl -mg, available.height);
			case Bottom(esize):
				var fl = esize.relativeTo(rectangle.height),
					mg = dock.margin.relativeTo(rectangle.height);
				panel.rectangle.set(available.x, available.y + available.height - fl, available.width, fl);
				available.set(available.x, available.y, available.width, available.height - fl - mg);
			case Left(esize):
				var fl = esize.relativeTo(rectangle.width),
					mg = dock.margin.relativeTo(rectangle.width);
				panel.rectangle.set(available.x, available.y, fl, available.height);
				available.set(available.x + fl + mg, available.y, available.width - fl -mg, available.height);
			case Fill:
		}
	}

	function afterUpdate() 
	{
		if(0 == fillqueue.length) return;
		var margin = 0.0,
			margins = [0.0];
		for(i in 0...fillqueue.length - 1)
		{
			margins[i+1] = docks.get(fillqueue[i]).margin.relativeTo(rectangle.width);
			margin += margins[i+1];
		}
		var w = (available.width - margin) / fillqueue.length,
			h = available.height,
			x = available.x,
			y = available.y;
		for(i in 0...fillqueue.length)
		{
			var rectangle = fillqueue[i].rectangle;
			rectangle.set(x + w * i + margins[i], y, w, h);
		}
	}
}

class Dock
{
	public var dock(default, null) : DockKind;
	public var margin(default, null) : Extent;
	public function new(defaultDock : DockKind, defaultMargin)
	{
		dock = defaultDock;
		margin = defaultMargin;
	}

	public function setDock(kind : DockKind, ?margin : Extent)
	{
		dock = kind;
		if(null != margin)
			this.margin = margin;
		return this;
	}

	public function dockLeft(size : Extent, ?margin : Extent)
		return setDock(Left(size), margin);

	public function dockRight(size : Extent, ?margin : Extent)
		return setDock(Right(size), margin);

	public function dockTop(size : Extent, ?margin : Extent)
		return setDock(Top(size), margin);

	public function dockBottom(size : Extent, ?margin : Extent)
		return setDock(Bottom(size), margin);

	public function fill()
	{
		dock = Fill;
		return this;
	}

	public function setMargin(margin : Extent)
	{
		this.margin = margin;
		return this;
	}
}

enum DockKind
{
	Top(size : Extent);
	Right(size : Extent);
	Bottom(size : Extent);
	Left(size : Extent);
	Fill;
}