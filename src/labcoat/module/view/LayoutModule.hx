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
package labcoat.module.view;

import precog.communicator.*;
import js.Browser;
import jQuery.JQuery;
import precog.layout.DockLayout;
import precog.layout.Panel;
import precog.layout.Extent;
import precog.html.HtmlPanel;
import labcoat.message.ApplicationHtmlContainer;
import labcoat.message.MainHtmlPanel;
import labcoat.message.MenuHtmlPanel;
import labcoat.message.SystemHtmlPanelGroup;
import labcoat.message.SupportHtmlPanelGroup;
import labcoat.message.ToolsHtmlPanelGroup;
import precog.geom.Rectangle;

using precog.html.HtmlPanelGroup;
using precog.html.JQuerys;
using thx.react.IObservable;
using thx.react.Promise;

import labcoat.config.ViewConfig;

class LayoutModule extends Module
{
	var container : JQuery;
	var mainLayout    : DockLayout;
	var contextLayout : DockLayout;

#if (html5 || cordova)
	var menu    : HtmlPanel;
#end
	var mainHtmlPanel : HtmlPanel;
	var contextPanel : Panel;
	var groups : LayoutGroups;

	function updateLayouts()
	{
		var size = container.getInnerSize(),
			vertical = size.width < size.height;

		// TODO, this should not be required but it is :(
		mainLayout.clear();
		contextLayout.clear();

		mainLayout.rectangle.set(0, 0, size.width, size.height);
#if (html5 || cordova)
//		mainLayout.addPanel(menu).dockTop(20);
#end
		groups.dockIfExists("tools", mainLayout, Bottom(groups.dockSize(["tools"], 100)));


		if(vertical) {
			mainLayout.addPanel(contextPanel).dockLeft(
				groups.dockSize(["system", "support"], 200)
			);
			groups.dockIfExists("system", contextLayout, groups.existsGroup("support") ? Top(0.5) : Fill);
			groups.dockIfExists("support", contextLayout, Fill, Left);
		} else {
			mainLayout.addPanel(contextPanel).dockLeft(groups.dockSize(["system"], 200));
			groups.dockIfExists("system", contextLayout, Fill);
			groups.dockIfExists("support", mainLayout, Right(groups.dockSize(["support"], 250)), Right);
		}
	
		mainLayout.addPanel(mainHtmlPanel).fill();
		mainLayout.update();
		contextLayout.update();
	}

	function onMessage(msg : ApplicationHtmlContainer, comm : Communicator)
	{

		container = msg.element;
		container.addClass("labcoat");
		groups = new LayoutGroups(container);
		contextPanel = new Panel();
#if (html5 || cordova)
		menu = new HtmlPanel("menu", container);
#end
		mainHtmlPanel = new HtmlPanel("main", container);

		mainLayout = new DockLayout(0, 0);
		contextLayout = new DockLayout(0, 0);

		mainLayout.defaultMargin = ViewConfig.panelMargin;
		contextLayout.defaultMargin = ViewConfig.panelMargin;

		contextPanel.rectangle.addListener(function(rect) {
			contextLayout.rectangle.set(rect.x, rect.y, rect.width, rect.height);
		});

        comm.provideLazy(
        	SystemHtmlPanelGroup,
        	function(deferred : Deferred<SystemHtmlPanelGroup>)
        	{
        		var g = new SystemHtmlPanelGroup(groups.ensureGroup("system", Left, updateLayouts).group);
        		updateLayouts();
	        	deferred.resolve(g);
        	}
        );

        comm.provideLazy(
        	SupportHtmlPanelGroup,
        	function(deferred : Deferred<SupportHtmlPanelGroup>)
        	{
        		var g = new SupportHtmlPanelGroup(groups.ensureGroup("support", Right, updateLayouts).group);
        		updateLayouts();
	        	deferred.resolve(g);
        	}
        );

        comm.provideLazy(
        	ToolsHtmlPanelGroup,
        	function(deferred : Deferred<ToolsHtmlPanelGroup>)
        	{
        		var g = new ToolsHtmlPanelGroup(groups.ensureGroup("tools", Bottom, updateLayouts).group);
        		updateLayouts();
	        	deferred.resolve(g);
        	}
        );

#if (html5 || cordova)
        comm.provide(new MenuHtmlPanel(menu));
#end
        comm.provide(new MainHtmlPanel(mainHtmlPanel));

		new JQuery(Browser.window).resize(function(_) updateLayouts());
	}

	override public function connect(comm : Communicator)
	{
		comm.demand(ApplicationHtmlContainer)
			.with(comm)
			.then(onMessage);
	}
}

class LayoutGroups
{
	var map : Map<String, { group : HtmlPanelGroup, panel : Panel }>;
	var container : JQuery;
	public function new(container : JQuery)
	{
		map = new Map();
		this.container = container;
	}

	public function ensureGroup(name : String, position : GutterPosition, update : Void -> Void)
	{
		var group = map.get(name);
		if(null == group)
			map.set(name, group = createGroup(name, position, update));
		return group;
	}

	public function getGroup(name : String)
	{
		return map.get(name);
	}

	public function existsGroup(name : String)
	{
		return map.exists(name);
	}

	function createGroup(name : String, position : GutterPosition, update : Void -> Void)
	{
		var panel  = new Panel(),
			result = {
				panel : panel,
				group : new HtmlPanelGroup(container, panel.rectangle, position),
			};
		result.group.events.activate.on(function(current) update());
		return result;
	}

	public function dockIfExists(name : String, layout : DockLayout, dock : DockKind, ?gutterPosition : GutterPosition)
	{
		var group = map.get(name);
		if(null == group)
			return;
		layout.addPanel(group.panel).setDock(dock);
		if(null != gutterPosition)
			group.group.gutterPosition = gutterPosition;
	}

	public function dockSize(names : Array<String>, openSize : Extent) : Extent
	{
		var found = null;
		for(name in names)
		{
			var group = map.get(name);
			if(null == group)
				continue;
			if(null != group.group.current)
				return openSize;
			found = group;
		}
		if(null == found)
			return Absolute(0);
		return Absolute(found.group.gutterSize);
	}
}