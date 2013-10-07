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

class HtmlButton 
{
	public var element(default, null) : JQuery;
	@:isVar public var text(get, set) : String;
	@:isVar public var title(get, set) : String;
	
	@:isVar public var leftIcon(get, set) : String;
	@:isVar public var size(get, set) : ButtonSize;
	@:isVar public var rightIcon(get, set) : String;
	@:isVar public var active(get, set) : Bool;
	@:isVar public var type(get, set) : ButtonType;
	@:isVar public var enabled(get, set) : Bool;

	public function new(?text : String, ?icon : String, ?btnsize : ButtonSize, ?textAsTitle = false)
	{
		element = new JQuery('<button type="button" class="btn"></button>');
		if(textAsTitle && null != text)
			this.title = title;
		else if(null != text)
			this.text = text;
		if(null != icon)
			this.leftIcon = icon;
		if(null == btnsize)
			btnsize = Default;
		this.size = btnsize;
		active = false;
		type = Default;
	}

	function get_text()
		return text;
	function set_text(text : String)
	{
		this.text = text;
		update();
		return text;
	}

	function get_title()
		return title;
	function set_title(title : String)
	{
		this.title = title;
		update();
		return title;
	}

	function get_leftIcon()
		return leftIcon;
	function set_leftIcon(icon : String)
	{
		this.leftIcon = icon;
		update();
		return text;
	}

	function get_rightIcon()
		return rightIcon;
	function set_rightIcon(icon : String)
	{
		this.rightIcon = icon;
		update();
		return text;
	}

	function get_active()
		return active;
	function set_active(state : Bool)
	{
		if(this.active == state) return state;
		this.active = state;
		this.element.toggleClass("active", state);
		return state;
	}

	function get_enabled()
		return enabled;
	function set_enabled(state : Bool)
	{
		if(this.enabled == state) return state;
		this.enabled = state;
		if(state)
			this.element.removeAttr("disabled");
		else
			this.element.attr("disabled", "disabled");
		return state;
	}

	function get_size()
		return size;
	function set_size(value : ButtonSize)
	{
		if(Type.enumEq(size, value)) return value;
		if(null != size) element.removeClass(ButtonSizes.toClass(size));
		size = value;
		element.addClass(ButtonSizes.toClass(size));
		return value;
	}

	function get_type()
		return type;
	function set_type(value : ButtonType)
	{
		if(Type.enumEq(type, value)) return value;
		if(null != type) switch(type)
		{
			case Default:
			case Primary:	element.removeClass("btn-primary");
			case Info:		element.removeClass("btn-info");
			case Success:	element.removeClass("btn-success");
			case Warning:	element.removeClass("btn-warning");
			case Danger:	element.removeClass("btn-danger");
			case Inverse:	element.removeClass("btn-inverse");
			case Link:		element.removeClass("btn-link");
			case Flat:		element.removeClass("btn-flat");
		}
		type = value;
		switch(type)
		{
			case Default:
			case Primary:	element.addClass("btn-primary");
			case Info:		element.addClass("btn-info");
			case Success:	element.addClass("btn-success");
			case Warning:	element.addClass("btn-warning");
			case Danger:	element.addClass("btn-danger");
			case Inverse:	element.addClass("btn-inverse");
			case Link:		element.addClass("btn-link");
			case Flat:		element.addClass("btn-flat");
		}
		return value;
	}

	function update()
	{
		var buf = [];
		if(null != leftIcon)
			buf.push('<i class="left-icon icon-$leftIcon"></i>');

		if(null != text)
		{
			var classes = ["text"];
			if(null != leftIcon)
				classes.push("with-left-icon");
			if(null != rightIcon)
				classes.push("with-right-icon");
			buf.push('<span class="${classes.join(" ")}">$text</span>');
		}

		if(null != rightIcon)
			buf.push('<i class="right-icon icon-$rightIcon"></i>');

		element.attr("title", title);
		element.html(buf.join(""));
	}
}

enum ButtonSize
{
	Large;
	Default;
	Small;
	Mini;
}

class ButtonSizes {
	public static function toClass(size: ButtonSize) {
		return switch(size) {
		case Large: "btn-large";
		case Default: "";
		case Small: "btn-small";
		case Mini: "btn-mini";
		}
	}
}

enum ButtonType
{
	Default;
	Primary;
	Info;
	Success;
	Warning;
	Danger;
	Inverse;
	Link;
	Flat;
}