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

import precog.fs.Node;
import precog.html.HtmlTree;
import precog.geom.IRectangle;
import jQuery.JQuery;
using precog.html.JQuerys;

class FSHtmlTreeRenderer implements IHtmlTreeRenderer<Node>
{
	var height : Float;
	var connectorWidth : Float;
	var toggleWidth : Float = 10;
	var margin : Float = 0;
	var tree : HtmlTree<Node>;
	public function new(height : Float, connectorWidth : Float = 10)
	{
		this.connectorWidth = connectorWidth;
		this.height = height;
	}
	public function setTree(tree : HtmlTree<Node>) : Void
	{
		this.tree = tree;
		tree.events.deselect.on(ondeselect);
		tree.events.select.on(onselect);
	}
	public function getRowHeight(rect : IRectangle) : Float
		return height;
	public function initRow(el : JQuery) : JQuery
	{
		el.html('<div class="tree-toggle" style="position:absolute"><i></i></div><div class="tree-content" style="white-space:nowrap"></div>');
		el.find(".tree-content")
			.clickOrDblClick(
				function(e) {
					e.preventDefault();
					tree.select(cast el.prop("data-node"));
					return false;
				},
				function(e) {
					e.preventDefault();
					tree.trigger(cast el.prop("data-node"));
					return false;
				}
			);
		return el;
	}
	public function updateRow(el : JQuery, node : TreeNode<Node>) : JQuery
	{
		el.prop("data-node", cast node); // The case is needed due to a limitation in jQuery Extern lib

		if(node == tree.selected)
			el.addClass("badge badge-light");

		var hwidth = (1 + node.level) * connectorWidth + margin,
			label  = Std.string(node.data).split("/").pop();
//		if(label == "")
//			label = "/";

		var icon,
			metatype = node.data.meta.get("type");
		if(null != metatype) {
			icon = 'icon-' + switch(metatype) {
				case "notebook" :	"book";
				case _:				"file";
			};
		} else if(node.data.isFile) {
			icon = 'icon-file';
		} else if(node.collapsed) {
			icon = 'icon-folder-close-alt';
		} else {
			icon = 'icon-folder-open-alt';
		}

		el.find(".tree-content")
			.css("margin-left", '${hwidth}px')
			.html('<i class="$icon"></i> ' + label);

		var toggle = el.find(".tree-toggle");
		if(node.collapsed || node.hasChildren) {
			toggle.get(0).onclick = function() {
				if(node.collapsed)
				{
					tree.expand(node);
				} else {
					tree.collapse(node);
				}
				node.toggle();
				tree.update();
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

	function onselect(node : TreeNode<Node>)
	{
		if(null == node) return;
		var el = tree.getElementForNode(node);
		if(null == el) return;
		el.addClass("badge badge-light");
	}

	function ondeselect(node : TreeNode<Node>)
	{
		if(null == node) return;
		var el = tree.getElementForNode(node);
		if(null == el) return;
		el.removeClass("badge badge-light");
	}
}