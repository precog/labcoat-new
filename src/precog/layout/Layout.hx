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

import precog.geom.Rectangle;
import precog.geom.IRectangleObservable;
import thx.react.IObservable;
import thx.react.Observable;

/**
TODO:
	- add GridLayout http://wpftutorial.net/GridLayout.html
	- add UniformGridLayout

quickstart: http://www.codeproject.com/Articles/30904/WPF-Layouts-A-Visual-Quick-Start
*/

@:access(precog.layout.Panel)
class Layout
{
	
	public var rectangle(default, null) : Rectangle;
	public var boundaries(get_boundaries, null) : IRectangleObservable;
	public var onpanel(default, null) : {
		add : IObservable<Panel>,
		remove : IObservable<Panel>
	};
	var measuredBoundaries : Rectangle;
	var panels : LayoutPanels;
	function new(width : Float, height : Float)
	{
		this.rectangle = new Rectangle(0, 0, width, height);
		this.measuredBoundaries = new Rectangle();
		this.panels = new LayoutPanels(this);
		this.onpanel = {
			add : panels.observableAdd,
			remove : panels.observableRemove
		};
	}

	inline function get_boundaries() return measuredBoundaries;

	var updateQueue : Array<Void -> Void>;
	function createUpdateQueue()
	{
		return [panelIteratorFunction(updatePanel)];
	}

	function panelIteratorFunction(f : Panel -> Void)
	{
		return function() {
			for(panel in panels)
				f(panel);
		}
	}

	public function update()
	{
		updateQueue = createUpdateQueue();
		measuredBoundaries.wrapSuspended(function() {
			for(panel in panels)
				panel.rectangle.suspend();
			resetBoundaries();
			while(updateQueue.length > 0)
				updateQueue.shift()();
			for(panel in panels)
				panel.rectangle.resume();
		});
	}

	function resetBoundaries()
	{
		measuredBoundaries.set(Math.NaN, Math.NaN, Math.NaN, Math.NaN);
	}

	function updatePanel(panel : Panel)
	{

	}

	public function iterator()
		return panels.iterator();

	public function clear()
		for(panel in panels)
			panel.remove();

	public function count() 
		return panels.count();

	public function toString()
		return Type.getClassName(Type.getClass(this)).split(".").pop() + '(${count()} children)';
}

@:access(precog.layout.Panel.setLayout)
class LayoutPanels
{
	var panels : Array<Panel>;
	var layout : Layout;
	public var observableAdd(default, null) : Observable<Panel>;
	public var observableRemove(default, null) : Observable<Panel>;
	public function new(layout : Layout)
	{
		this.layout = layout;
		panels = [];
		observableAdd = new Observable<Panel>();
		observableRemove = new Observable<Panel>();
	}

	public function addPanel(panel : Panel)
	{
		panel.setLayout(layout);
		panels.push(panel);
		observableAdd.notify(panel);
	}

	public function removePanel(panel : Panel)
	{
		panel.setLayout(null);
		panels.remove(panel);
		observableRemove.notify(panel);
	}

	public function count()
		return panels.length;

	public function clear()
	{
		var all = panels.copy();
		while(all.length > 0)
			removePanel(all.shift());
	}

	inline public function iterator()
		return panels.copy().iterator();
}