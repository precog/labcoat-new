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

import jQuery.JQuery;
import precog.geom.IRectangle;
import haxe.Timer;
using thx.react.IObservable;
using thx.react.Signal;

class TreeNode<T>
{
	public var parent(default, null) : TreeNode<T>;
	public var level(default, null) : Int;
	public var before(default, null) : TreeNode<T>;
	public var after(default, null) : TreeNode<T>;
	public var firstChild(default, null) : TreeNode<T>;
	public var lastChild(default, null) : TreeNode<T>;
	public var tree(default, null) : Tree<T>;
	public var collapsed(default, null) : Bool;
	public var data : T;
	public function new(tree : Tree<T>, data : T)
	{
		this.tree = tree;
		this.data = data;
		this.collapsed = false;
	}

	public var hasChildren(get, null) : Bool;
	inline function get_hasChildren() 
		return firstChild != null;

	public function collapse()
	{
		if(collapsed) return;
		collapsed = true;
		tree.dirty = true;
	}

	public function expand()
	{
		if(!collapsed) return;
		collapsed = false;
		tree.dirty = true;
	}

	public function toggle()
	{
		if(collapsed)
			expand();
		else
			collapse();
	}

	public function appendChild(data : T)
	{
		var node = new TreeNode(tree, data);
		node.parent = this;
		node.level = level + 1;
		if(null != lastChild)
		{
			lastChild.after = node;
			node.before = lastChild;
		} else {
			firstChild = node;
		}
		lastChild = node;
		tree.dirty = true;
		return node;
	}

	public function prependChild(data : T)
	{
		var node = new TreeNode(tree, data);
		node.parent = this;
		node.level = level + 1;
		if(null != firstChild)
		{
			firstChild.before = node;
			node.after = firstChild;
		} else {
			lastChild = node;
		}
		firstChild = node;
		tree.dirty = true;
		return node;
	}

	public function insertAfter(data : T)
	{
		var node = new TreeNode(tree, data);
		node.parent = parent;
		node.level = level;
		node.before = this;
		node.after = after;
		if(null != after)
			after.before = node;
		else if(null != parent)
			parent.lastChild = node;
		after = node;
		tree.dirty = true;
		return node;
	}

	public function insertBefore(data : T)
	{
		var node = new TreeNode(tree, data);
		node.parent = parent;
		node.level = level;
		node.before = before;
		node.after = this;
		if(null != before)
			before.after = node;
		else if(null != parent)
			parent.firstChild = node;
		before = node;
		tree.dirty = true;
		return node;
	}

	public function appendChildOrdered(data : T)
	{

		for(node in iterator())
		{
			var c = tree.compare(data, node.data);
			if(c < 0) {
				return node.insertBefore(data);
			} else if(c == 0) {
				return node.insertAfter(data);
			}
		}
		return appendChild(data);
	}

	public function iterator() : Iterator<TreeNode<T>>
	{
		var list = [],
			node = firstChild;
		while(null != node)
		{
			list.push(node);
			node = node.after;
		}
		return list.iterator();
	}

	public function remove()
	{
		if(null != parent) {
			if(parent.firstChild == this)
				parent.firstChild = after;
			if(parent.lastChild == this)
				parent.lastChild = before;
		}
		if(null != before)
			before.after = after;
		if(null != after)
			after.before = before;
		after = before = null;
		tree.dirty = true;
	}
}

@:access(precog.html.TreeNode)
class Tree<T>
{
	public var root(default, null) : TreeNode<T>;
	public var compare : T -> T -> Int;

	public function new() 
	{
		dirty = false;
		list = [];
		this.compare = function(a, b) return 1;
	}

	public function addRoot(data : T)
	{
		if(null == root)
		{
			root = new TreeNode(this, data);
			root.level = 0;
			return root;
		} else {
			var end = root;
			while(null != end.after)
				end = end.after;
			return end.insertAfter(data);
		}
	}

	public function update()
	{
		if(!dirty || root == null) return;

		var start = root;
		while(null != start.before)
			start = start.before;
		root = start;
		list = [];
		traverse(root);

		dirty = false;
	}

	public var list(default, null) : Array<TreeNode<T>>;
	function traverse(node : TreeNode<T>)
	{
		list.push(node);
		if(!node.collapsed && null != node.firstChild)
			traverse(node.firstChild);
		if(null != node.after)
			traverse(node.after);
	}

	public var dirty : Bool;
}

class TreeEvents<T> implements precog.macro.ValueClass
{
	var select : Signal1<TreeNode<T>>;
	var deselect : Signal1<TreeNode<T>>;
	var trigger : Signal1<TreeNode<T>>;
	var expand : Signal1<TreeNode<T>>;
	var collapse : Signal1<TreeNode<T>>;
}

class HtmlTree<T>
{
	var tree : Tree<T>;
	var rowHeight : Null<Float>;
	var sampler : Void -> Void;
	var height : Float;

	var scroller : JQuery;
	var rows : Array<JQuery>;
	var renderer : IHtmlTreeRenderer<T>;

	public var panel : HtmlPanel;
	public var events(default, null) : TreeEvents<T>;
	public var selected(default, null) : Null<TreeNode<T>>;
	public var compare(get, set) : T -> T -> Int;

	public function new(panel : HtmlPanel, renderer : IHtmlTreeRenderer<T>)
	{
		this.panel = panel;
		scroller = new JQuery('<div clss="tree-scroller" style="position:absolute;width:100%"></div>');
		tree = new Tree();
		
		events = new TreeEvents(
			new Signal1<TreeNode<T>>(),
			new Signal1<TreeNode<T>>(),
			new Signal1<TreeNode<T>>(),
			new Signal1<TreeNode<T>>(),
			new Signal1<TreeNode<T>>()
		);

		this.renderer = renderer;
		renderer.setTree(this);
		// init elements
		panel.element.addClass("tree");
		panel.element.css("overflow", "auto");
		panel.element.append(scroller);
		panel.element.scroll(function(_) delayedUpdate());
		// update rows
		panel.rectangle.addListener(function(rect) {
			calculateRowHeight();
			update();
		});
		rows = [];
		calculateRowHeight();
	}

	function createRow()
	{
		return renderer.initRow(new JQuery('<div class="tree-row" style="position:absolute"></div>'));
	}

	public function addRoot(data : T)
	{
		return tree.addRoot(data);
	}

	var timer : Timer;
	public function delayedUpdate()
	{
		if(null != timer)
			timer.stop();
		timer = Timer.delay(function() {
			update();
			timer = null;
		}, 15);
	}

	public function select(node : TreeNode<T>)
	{
		if(null != selected)
			events.deselect.trigger(selected);
		selected = node;
		events.select.trigger(selected);
	}

	public function trigger(node : TreeNode<T>)
	{
		events.trigger.trigger(node);
	}

	public function collapse(node : TreeNode<T>)
	{
		events.collapse.trigger(node);
	}

	public function expand(node : TreeNode<T>)
	{
		events.expand.trigger(node);
	}

	public function update()
	{
		tree.update();
		var 
			scroll          = panel.element.scrollTop(),
			start_index     = Math.floor(scroll / rowHeight),
			items_total     = tree.list.length,
			height_total    = items_total * rowHeight,
			height_page     = panel.rectangle.height,
			items_page      = Math.ceil(height_page / rowHeight) * 2 + 1, // look ahead 1 page
			items_visibles  = Math.round(Math.min(items_total - start_index, items_page)),
			height_scroller = Math.max(height_page, height_total)
		;

		// remove excess
		while(rows.length > items_visibles)
			rows.pop().remove();
		// fill needed
		while(rows.length < items_visibles)
			rows.push(createRow().appendTo(scroller));

		// resize container
		if(height_scroller != scroller.outerHeight())
			scroller.css("height", height_scroller +"px");

		var top = scroll - scroll % rowHeight;

		nodeToElMap = new Map();
		// render nodes
		for(row in rows)
		{
			var node = tree.list[start_index];
			nodeToElMap.set(node, row);
			row.css("top", top + "px");
			renderer.updateRow(row, node);

			start_index++;
			top += rowHeight;
		}
	}

	var nodeToElMap : Map<TreeNode<T>, JQuery>;
	public function getElementForNode(node : TreeNode<T>)
	{
		if(null == nodeToElMap) return null;
		return nodeToElMap.get(node);
	}

	// TODO implement
	function calculateRowHeight()
	{
		rowHeight = renderer.getRowHeight(panel.rectangle);
	}

	function get_compare()
	{
		return tree.compare;
	}

	function set_compare(f)
	{
		return tree.compare = f;
	}
}

interface IHtmlTreeRenderer<T>
{
	public function setTree(tree : HtmlTree<T>) : Void;
	public function getRowHeight(rect : IRectangle) : Float;
	public function initRow(el : JQuery) : JQuery;
	public function updateRow(el : JQuery, node : TreeNode<T>) : JQuery;
}

class BaseHtmlTreeRenderer<T> implements IHtmlTreeRenderer<T>
{
	var height : Float;
	var connectorWidth : Float;
	var toggleWidth : Float = 10;
	var margin : Float = 0;
	var tree : HtmlTree<T>;
	public function new(height : Float, connectorWidth : Float = 10)
	{
		this.connectorWidth = connectorWidth;
		this.height = height;
	}
	public function setTree(tree : HtmlTree<T>) : Void
	{
		this.tree = tree;
	}
	public function getRowHeight(rect : IRectangle) : Float
		return height;
	public function initRow(el : JQuery) : JQuery
	{
		el.html('<div class="tree-toggle" style="position:absolute"><i></i></div><div class="tree-content" style="white-space:nowrap"></div>');
		return el;
	}
	public function updateRow(el : JQuery, node : TreeNode<T>) : JQuery
	{
		var hwidth = (1 + node.level) * connectorWidth + margin,
			label  = Std.string(node.data).split("/").pop();
//		if(label == "")
//			label = "/";

		el.find(".tree-content")
			.css("margin-left", '${hwidth}px')
			.html('<i class="' + (node.hasChildren ? 'icon-folder-${node.collapsed ? "close" : "open"}-alt' : 'icon-file' ) + '"></i> ' + label);

		var toggle = el.find(".tree-toggle");
		if(node.collapsed || node.hasChildren) {
			toggle.get(0).onclick = function(e) {
				e.preventDefault();
				node.toggle();
				tree.update();
				return false;
			};
			if(node.collapsed) {
				toggle.find("i").removeClass("icon-caret-down").addClass("icon-caret-right");
			} else {
				toggle.find("i").removeClass("icon-caret-right").addClass("icon-caret-down");
			}
			toggle.css("left", (hwidth-toggleWidth-margin)+"px");
			toggle.show();
		} else {
			toggle.hide();
		}
		return el;
	}
}