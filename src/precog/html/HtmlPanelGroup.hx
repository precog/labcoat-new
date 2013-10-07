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
package precog.html;

import haxe.ds.Option;
import jQuery.JQuery;
import precog.geom.IRectangle;
import precog.geom.IRectangleObservable;
import precog.html.HtmlDropdown;
import precog.layout.DockLayout;
import precog.layout.Panel;
import thx.react.IObserver;
import thx.react.Signal;
using thx.react.IObservable;
using precog.html.JQuerys;
using precog.html.HtmlButton;

@:access(precog.html.HtmlPanelGroupItem.setGroup)
class HtmlPanelGroup implements IObserver<IRectangle>
{
	public var length(default, null) : Int;
	var items : Array<HtmlPanelGroupItem>;
	public var current(default, null) : HtmlPanelGroupItem;
	public var container(default, null) : JQuery;
	public var pane(default, null) : Panel;
	public var gutter(default, null) : HtmlPanel;
	public var togglesContainer(default, null) : JQuery;
	var layout : DockLayout;
	public var gutterMargin : Int = 0;
	public var gutterSize(default, null) : Int;
	public var events(default, null) : {
		public var activate(default, null) : Signal1<HtmlPanelGroupItem>;
	};
	@:isVar public var toggleSize(get, set) : ButtonSize;
	public var toggleType : ButtonType;
	public var tabMode(default, null) : Bool;

	@:isVar public var gutterPosition(get_gutterPosition, set_gutterPosition) : GutterPosition;

	public function new(parent : JQuery, rectangle : IRectangleObservable, ?gutterPosition : GutterPosition, ?plusItems : Array<DropdownItem>)
	{
		events = {
			activate : new Signal1()
		};
		tabMode = plusItems != null;
		length = 0;
		items = [];
		current = null;
		container = parent;
		toggleSize = Mini;
		toggleType = Default;
		layout = new DockLayout(0, 0);
		pane   = new Panel();
		gutter = new HtmlPanel();
		togglesContainer = new JQuery('<div class="btn-group"></div>').appendTo(gutter.element);
		gutter.element.addClass("gutter");
		if(tabMode) {
			gutter.element.addClass("tabs");
			addPlusButton(plusItems);
		}

		container.append(gutter.element);

		if(null == gutterPosition)
			gutterPosition = Top;
		this.gutterPosition = gutterPosition;
		rectangle.addListener(update);
		update(rectangle);
	}

	function get_toggleSize()
		return toggleSize;
	function set_toggleSize(value)
	{
		toggleSize = value;
		var button = new HtmlButton("Sample", value),
			div    = new JQuery('<div class="gutter"></div>').appendTo(new JQuery(".labcoat")),
			group  = new JQuery('<div class="btn-group"></div>').appendTo(div);
		if(tabMode)
			div.addClass("tabs");
		button.element.appendTo(group);
		gutterSize = button.element.outerHeight(true);
		var parent = container.parent();
		div.remove();
		return value;
	}

	public function update(rect : IRectangle) {
		layout.rectangle.set(rect.x, rect.y, rect.width, rect.height);
		layout.update();
	}

	function addPlusButton(plusItems: Array<DropdownItem>)
	{
		var button = new JQuery('<button type="button" class="btn dropdown-toggle icon-plus" data-toggle="dropdown"></button>');
		var menu = DropdownItems.groupToHtml(plusItems);
		new JQuery('<div class="btn-group"></div>').append(button).append(menu).appendTo(gutter.element);
	}

	public function addItem(item : HtmlPanelGroupItem) 
	{
		items.remove(item);
		items.push(item);
		item.setGroup(this);
		togglesContainer.append(item.toggle.element);
		container.append(item.panel.element);
		length = items.length;
		updateVerticalPosition();
		pane.rectangle.attach(item.panel);
		item.panel.update(pane.rectangle);
		if(tabMode && length == 1)
			item.activate();
	}

	public function removeItem(item : HtmlPanelGroupItem) 
	{
		if(!items.remove(item)) return;
		item.toggle.element.detach();
		item.panel.element.detach();
		pane.rectangle.detach(item.panel);
		updateVerticalPosition();
		if(tabMode && current == item && items.length > 0)
		{
			items[items.length - 1].activate();
		}
		item.setGroup(null);
		length = items.length;
	}

	function activate(item : HtmlPanelGroupItem)
	{
		current = item;
		for(other in items)
			if(other != item)
				other.deactivate();
	}

	function deactivate(item : HtmlPanelGroupItem)
	{
		if(tabMode && current == item)
			return false;
		if(current == item)
			current = null;
		return true;
	}

	function get_gutterPosition()
		return gutterPosition;

	function set_gutterPosition(position : GutterPosition)
	{
		if(null != gutterPosition) switch (gutterPosition) {
			case Top:
				gutter.element.removeClass("top");
			case Bottom:
				gutter.element.removeClass("bottom");
			case Left:
				gutter.element.removeClass("left");
			case Right:
				gutter.element.removeClass("bottom");
		}
		gutterPosition = position;
		layout.clear();
		togglesContainer
                    .css("top",  '0px')
                    .css("left", '0px');
		switch (gutterPosition) {
			case Top:
				gutter.element.addClass("top");
				layout.addPanel(gutter).dockTop(gutterSize, gutterMargin);
			case Bottom:
				gutter.element.addClass("bottom");
				layout.addPanel(gutter).dockBottom(gutterSize, gutterMargin);
			case Left:
				gutter.element.addClass("left");
				layout.addPanel(gutter).dockLeft(gutterSize, gutterMargin);
			case Right:
				gutter.element.addClass("right");
				layout.addPanel(gutter).dockRight(gutterSize, gutterMargin);
		}
		layout.addPanel(pane).fill();
		updateVerticalPosition();
		layout.update();
		return position;
	}

	function updateVerticalPosition() {
		switch (gutterPosition) {
			case Left:
				var size = togglesContainer.getOuterSize(),
					w = size.width,
					h = size.height;
				var offset = (w - h) / 2;
				togglesContainer.cssTransform('rotateZ(-90deg) translate3d(-${offset}px, -${offset}px, 0)');
			case Right:
				var size = togglesContainer.getOuterSize(),
					w = size.width,
					h = size.height;
				var offset = (w - h) / 2;
				togglesContainer.cssTransform('rotateZ(90deg) translate3d(${offset}px, ${offset}px, 0)');
			case _:
				togglesContainer.cssTransform('none');
		}
	}
}

enum GutterPosition
{
	Top;
	Right;
	Bottom;
	Left;
}

@:access(precog.html.HtmlPanelGroup)
class HtmlPanelGroupItem 
{
	public var toggle(default, null) : HtmlButton;
	public var panel(default, null) : HtmlPanelSwap;
	public var group(default, null) : HtmlPanelGroup;
	public var active(default, null) : Bool;

	public function new(label : String, ?icon : String)
	{
		this.active = false;
		this.toggle = new HtmlButton(label, icon);
		
//		this.toggle.rightIcon = Icons.heart;
		this.panel = new HtmlPanelSwap();
		this.panel.hide();
		this.toggle.element.bind("click", null, click);
	}

	function click(_) 
	{
		if(active)
			deactivate();
		else
			activate();
	}

	public function activate()
	{
		if(null == group || active) return;
		group.activate(this);
		toggle.active = active = true;
		panel.show();
		group.events.activate.trigger(this);
	}

	public function deactivate()
	{
		if(null == group || !active) return;
		if(group.deactivate(this))
		{
			toggle.active = active = false;
			panel.hide();
			group.events.activate.trigger(null);
		}
	}

	function setGroup(group : HtmlPanelGroup)
	{
		this.group = group;
		if(null != group) {
			this.toggle.size = group.toggleSize;
			this.toggle.type = group.toggleType;
		} else {
			active = false;
		}
	}

	public function toString()
		return 'HtmlGroupItem (${toggle.text})';
}