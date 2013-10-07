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
package precog.editor;

import jQuery.JQuery;

class TextAreaEditor
{
	public var element(default, null) : JQuery;
	public function new()
	{
		element = new JQuery('<textarea class="textarea-editor editor"></textarea>');
		autoresize(element);
	}
	public function getValue() : String
	{
		return element.val();
	}
	public function setValue(text : String) 
	{
		element.val(text);
	}
	public function refresh() : Void
	{

	}
	public function focus() : Void
	{
		element.focus();
	}
	public function getWrapperElement() : js.html.Element;
	{
		return element.get(0);
	}

	static function autoresize(element : JQuery)
	{
		var t = element.get(0);
		untyped __js__("var offset= !window.opera ? (t.offsetHeight - t.clientHeight) : (t.offsetHeight + parseInt(window.getComputedStyle(t, null).getPropertyValue('border-top-width'))) ;
 console.log(offset);
    var resize  = function(t) {
console.log(t.scrollHeight);
        t.style.height = 'auto';
console.log(t.scrollHeight);
        t.style.height = (t.scrollHeight  + offset ) + 'px';    
    }
 
    t.addEventListener && t.addEventListener('input', function(event) {
        resize(t);
    });
 
    t['attachEvent']  && t.attachEvent('onkeyup', function() {
        resize(t);
    });");
	}
}