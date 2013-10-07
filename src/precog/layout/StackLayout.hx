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

/**
TODO:
	- add right-to-left
	- add bottom-to-top
*/
class StackLayout extends Layout 
{
	var items : Map<Panel, StackItem>;
	public var defaultExtent : Extent;
	public var defaultMargin : Extent;
	public var vertical : Bool;
	public function new(width : Float, height : Float, ?vertical = true)
	{
		super(width, height);
		defaultExtent = 20;
		defaultMargin = 0;
		items = new Map();
		this.vertical = vertical;
		onpanel.remove.addListener(function(panel) {
			items.remove(panel);
		});
	}

	public function addPanel(panel : Panel) : StackItem
	{
		var item = new StackItem(defaultExtent, defaultMargin);
		panels.addPanel(panel);
		items.set(panel, item);
		return item;
	}

	override function createUpdateQueue()
	{
		return vertical
			? [panelIteratorFunction(updatePanelVertical)]
			: [panelIteratorFunction(updatePanelHorizontal)];
	}

	var offset : Float;
	override function resetBoundaries()
	{
		measuredBoundaries.set(Math.NaN, Math.NaN, Math.NaN, Math.NaN);
		offset = 0.0;
	}

	function updatePanelVertical(panel)
	{
		var item = items.get(panel),
			height = item.extent.relativeTo(rectangle.height);
		panel.rectangle.set(
			rectangle.x,
			rectangle.y + offset,
			rectangle.width,
			height
		);
		offset += height;
		if(Math.isNaN(measuredBoundaries.x)) {
			measuredBoundaries.set(
				rectangle.x,
				rectangle.y,
				rectangle.width,
				height
			);
		} else {
			measuredBoundaries.set(
				measuredBoundaries.x,
				measuredBoundaries.y,
				measuredBoundaries.width,
				offset
			);
		}
		offset += item.margin.relativeTo(rectangle.height);
	}

	function updatePanelHorizontal(panel)
	{
		var item = items.get(panel),
			width = item.extent.relativeTo(rectangle.width);
		panel.rectangle.set(
			rectangle.x + offset,
			rectangle.y,
			width,
			rectangle.height
		);
		offset += width;
		if(Math.isNaN(measuredBoundaries.x)) {
			measuredBoundaries.set(
				rectangle.x,
				rectangle.y,
				width,
				rectangle.height
			);
		} else {
			measuredBoundaries.set(
				measuredBoundaries.x,
				measuredBoundaries.y,
				offset,
				measuredBoundaries.height
			);
		}
		offset += item.margin.relativeTo(rectangle.width);
	}
}

class StackItem 
{
	public var extent(default, null) : Extent;
	public var margin(default, null) : Extent;
	public function new(defaultExtent : Extent, defaultMargin : Extent)
	{
		extent = defaultExtent;
		margin = defaultMargin;
	}

	public function setExtent(extent : Extent)
	{
		this.extent = extent;
		return this;
	}

	public function setMargin(margin : Extent)
	{
		this.margin = margin;
		return this;
	}
}