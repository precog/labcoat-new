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
import precog.html.JQuerys;
import thx.core.Procedure;

class Dialog
{
	public static function confirm(message : String, success : Void -> Void)
	{
		var cancel = new HtmlButton("cancel"),
			ok = new HtmlButton("OK");
		ok.type = Primary;
		var dialog = createEmptyDialog({ keyboard : true }),
			el = dialog.el();
		el.find(".modal-header").hide();
		el.find(".modal-body").html(message);
		el.find(".modal-footer")
			.append(cancel.element)
			.append(ok.element);
		el.on("hidden", function() {
			el.remove();
		});
		ok.element.addClass("ok");
		ok.element.get(0).onclick = function() {
			dialog.hide();
			success();
		};
		cancel.element.addClass("cancel");
		cancel.element.get(0).onclick = function() {
			dialog.hide();
		};

		thx.react.promise.Timer.delay(200).then(function() { ok.element.focus(); });
		el.on("keypress", function(e) {
			if(e.which == 13)
				ok.element.click();
		});
		return {
			dialog : dialog,
			ok : ok,
			cancel : cancel
		};
	}

	static function emptyValidator(v : String, handler : Null<String> -> Void)
	{
		handler(null);
	}

	public static function prompt(message : String, ?defaultValue : String, success : String -> Void, ?validator : String -> (Null<String> -> Void) -> Void)
	{
		validator = null == validator ? emptyValidator : validator;
		var item	= confirm(message, null),
			ok		= item.ok,
			cancel	= item.cancel,
			dialog	= item.dialog,
			el		= dialog.el(),
			body	= el.find(".modal-body"),
			input	= new JQuery('<input type="text" class="prompt-value">').appendTo(new JQuery('<div class="prompt-input-container"></div>').appendTo(body)),
			error	= new JQuery('<div class="prompt-alert alert alert-error" style="display:none"></div>').appendTo(body);

		if(null != defaultValue)
			input.val(defaultValue);
		ok.element.get(0).onclick = function() {
			cancel.enabled = ok.enabled = false;
			error.hide();
			var value = input.val();

			validator(value, function(msg) {
				if(null == msg) {
					dialog.hide();
					success(value);
				} else {
					cancel.enabled = ok.enabled = true;
					error.html(msg);
					error.show();
				}
			});
		};

		thx.react.promise.Timer.delay(250).then(function() { input.focus(); });
		return dialog;
	}

	static function createEmptyDialog(?options : OptBootstrapModal)
	{
		return Bootstrap.modal(new JQuery(DIALOG_HTML), options);
	}

	static var DIALOG_HTML = '<div class="modal hide fade in labcoat-dialog modal-small" role="dialog" aria-labelledby="dialog" aria-hidden="false" style="display: block;">
  <div class="modal-header"></div>
  <div class="modal-body"></div>
  <div class="modal-footer"></div>
<!--	<button id="account-create" class="btn btn-primary" tabindex="10">Create Account</button> -->
</div>';
}

@:native("bootstrap") extern class Bootstrap
{
	public static inline function modal(el : JQuery, ?options : OptBootstrapModal) : Modal
		return new Modal(el, options);

	public static inline function alert(el : JQuery) : Alert
		return new Alert(el);

    static function __init__() : Void
    {
        JQuerys;
        haxe.macro.Compiler.includeFile("precog/html/bootstrap.js");
    }
}

abstract Alert(Dynamic)
{
	public function new(el : JQuery) {
		this = untyped el.alert();
	}

	public inline function close() : Modal
		return this.modal('close');

}

abstract Modal(Dynamic)
{
	public function new(el : JQuery, ?options : OptBootstrapModal) {
		this = untyped el.modal(options);
	}

	public inline function toggle() : Modal
		return this.modal('toggle');

	public inline function show() : Modal
		return this.modal('show');

	public inline function hide() : Modal
		return this.modal('hide');

	public inline function el() : JQuery
		return cast this;

	public inline function onShow<T>(handler : ProcedureDef<T>) : Modal
		return this.el().on("show", handler);

	public inline function onShown<T>(handler : ProcedureDef<T>) : Modal
		return this.el().on("shown", handler);

	public inline function onHide<T>(handler : ProcedureDef<T>) : Modal
		return this.el().on("hide", handler);

	public inline function onHidden<T>(handler : ProcedureDef<T>) : Modal
		return this.el().on("hidden", handler);
}

typedef OptBootstrapModal = {
	?backdrop : Dynamic,
	?keyboard : Bool,
	?show : Bool,
	?remote : String
}