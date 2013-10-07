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

@:access(precog.geom.Point)
class CanvasLayout extends Layout
{
	var canvases : Map<Panel, Canvas>;
	public function new(width : Float, height : Float)
	{
		super(width, height);
		canvases = new Map();
		onpanel.remove.addListener(function(panel) {
			canvases.remove(panel);
		});
	}

	public function addPanel(panel : Panel) : Canvas
	{
		var canvaspanel = new Canvas();
		panels.addPanel(panel);
		canvases.set(panel, canvaspanel);
		return canvaspanel;
	}

	override function resetBoundaries()
	{
		measuredBoundaries.set(Math.NaN, Math.NaN, Math.NaN, Math.NaN);
	}

	override function updatePanel(panel)
	{
		var c = canvases.get(panel);
		panel.rectangle.set(
			rectangle.x + c.x.relativeTo(rectangle.width) + anchorX(c.layoutAnchor, rectangle.width) - anchorX(c.panelAnchor, panel.rectangle.width),
			rectangle.y + c.y.relativeTo(rectangle.height) + anchorY(c.layoutAnchor, rectangle.height) - anchorY(c.panelAnchor, panel.rectangle.height),
			c.width.relativeTo(rectangle.width),
			c.height.relativeTo(rectangle.height)
		);
		if(Math.isNaN(measuredBoundaries.x)) {
			measuredBoundaries.set(
				panel.rectangle.x,
				panel.rectangle.y,
				panel.rectangle.width,
				panel.rectangle.height
			);
		} else {
			measuredBoundaries.addRectangle(panel.rectangle);
		}
	}

	static function anchorX(anchor : CanvasAnchor, width : Float)
	{
		return switch (anchor) {
			case TopLeft, Left, BottomLeft:
				0.0;
			case Top, Center, Bottom:
				width / 2;
			case TopRight, Right, BottomRight:
				width;
		}
	}

	static function anchorY(anchor : CanvasAnchor, height : Float)
	{
		return switch (anchor) {
			case TopLeft, Top, TopRight:
				0.0;
			case Left, Center, Right:
				height / 2;
			case BottomLeft, Bottom, BottomRight:
				height;
		}
	}
}

class Canvas
{
	public var layoutAnchor(default, null) : CanvasAnchor;
	public var panelAnchor(default, null) : CanvasAnchor;
	public var width(default, null) : Extent;
	public var height(default, null) : Extent;
	public var x(default, null) : Extent;
	public var y(default, null) : Extent;
	public function new()
	{
		this.layoutAnchor = TopLeft;
		this.panelAnchor = TopLeft;
		this.width = 0;
		this.height = 0;
		this.x = 0;
		this.y = 0;
	}

	public function setLayoutAnchor(anchor : CanvasAnchor)
	{
		this.layoutAnchor = anchor;
		return this;
	}

	public function setPanelAnchor(anchor : CanvasAnchor)
	{
		this.panelAnchor = anchor;
		return this;
	}

	public function setSize(width : Extent, height : Extent)
	{
		this.width = width;
		this.height = height;
		return this;
	}

	public function setOffset(x : Extent, y : Extent)
	{
		this.x = x;
		this.y = y;
		return this;
	}
}

enum CanvasAnchor
{
	Center;
	TopLeft;
	Top;
	TopRight;
	Left;
	Right;
	BottomLeft;
	Bottom;
	BottomRight;
}