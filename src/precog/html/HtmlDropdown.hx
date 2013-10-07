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
import jQuery.Event;
import precog.html.HtmlButton;
import precog.html.Bootstrap;

class HtmlDropdown {
    public var element(default, null) : JQuery;

    public function new(text: String, icon: String, classes: String, size: ButtonSize, items: Array<DropdownItem>, align: DropdownAlignment) {
        var pull = switch(align) {
        case DropdownAlignRight: "pull-right";
        case DropdownAlignLeft: "";
        }

        element = new JQuery('<div class="buttons dropdown ${classes} ${pull}"></div>');

        var button = new JQuery('<button class="btn ${ButtonSizes.toClass(size)} dropdown-toggle" data-toggle="dropdown">${text}</button>').appendTo(element);
        if(icon.length > 0) button.addClass("icon-" + icon);

        DropdownItems.groupToHtml(items).addClass(pull).appendTo(element);
    }
}

enum DropdownItem {
    DropdownButton(text: String, classes: String, action: Event -> Void);
    DropdownDivider;
}

class DropdownItems {
    public static function groupToHtml(group: Array<DropdownItem>) {
        var menu = new JQuery('<ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu"></ul>');
        for(item in group) {
            var itemElement = DropdownItems.itemToHtml(item);
            itemElement.appendTo(menu);
        }
        return menu;
    }

    static function itemToHtml(item: DropdownItem) {
        return switch(item) {
        case DropdownDivider: new JQuery('<li class="divider"></li>');
        case DropdownButton(text, classes, action): new JQuery('<li class="${classes}"><a tabindex="-1" href="#">${text}</a></li>').click(action);
        }
    }
}

enum DropdownAlignment {
    DropdownAlignRight;
    DropdownAlignLeft;
}
