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
import precog.layout.Panel;
import precog.geom.IRectangle;
import precog.geom.IRectangleObservable;
import thx.react.IObserver;
import thx.react.promise.Timer;

class HtmlPanel extends Panel implements IObserver<IRectangle>
{
	public var element(default, null) : JQuery;
	public function new(cls : String = "", ?container : JQuery)
	{
		super();
		element = new JQuery('<div class="panel $cls" style="position:absolute"></div>');
//		Timer.delay(0).then(element.addClass.bind("animate-all"));
		rectangle.attach(this);
		if(null != container)
			element.appendTo(container);
	}

	public function update(rect : IRectangle)
	{
		rectangle.set(rect.x, rect.y, rect.width, rect.height);
		element
                    .css("top",    rect.y + "px")
                    .css("left",   rect.x + "px")
                    .css("width",  rect.width + "px")
                    .css("height", rect.height + "px");
	}

	public function destroy()
	{
		rectangle.detach(this);
		element.remove();
	}
}