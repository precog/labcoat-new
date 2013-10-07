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

using precog.geom.Rectangle;

@:access(precog.layout.Layout)
class Panel 
{
	public var rectangle(default, null) : Rectangle;
	public var parentLayout(default, null) : Layout;
	public function new()
	{
		rectangle = new Rectangle(0, 0, 0, 0);
	}

	private function setLayout(layout : Layout)
	{
		(function(oldParent : Layout) {
			parentLayout = layout;
			if(null != oldParent)
				oldParent.panels.removePanel(this);
		})(parentLayout);
	}

	public function remove()
		setLayout(null);

	public function toString()
		return 'Panel(${rectangle.x}, ${rectangle.y}, ${rectangle.width}, ${rectangle.height}, layout: $parentLayout)';
}