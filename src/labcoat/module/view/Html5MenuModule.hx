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

import labcoat.message.MenuHtmlPanel;
import labcoat.message.MenuItem;
import precog.communicator.Communicator;
import precog.communicator.Module;
import precog.html.HtmlButton;
import precog.html.HtmlDropdown;
import precog.html.HtmlPanel;
import precog.macro.ValueClass;
import precog.util.Locale;
import jQuery.JQuery;

using thx.react.Promise;

class WeightedDropdownItem implements ValueClass {
    var weight: Int;
    var item: DropdownItem;
}

class Html5MenuGroup implements ValueClass {
    var dropdown: HtmlDropdown;
    var subgroups: Array<Array<WeightedDropdownItem>>;

    public function replaceDropdown(newDropdown: HtmlDropdown) {
        dropdown.element.replaceWith(newDropdown.element);
        dropdown = newDropdown;
    }
}

class Html5MenuModule extends Module {
    var element: JQuery;
    var groups: Array<Html5MenuGroup>;
    var panel : HtmlPanel;

    public function new() {
        super();
        groups = [];
    }

    override public function connect(communicator: Communicator) {
        communicator
            .demand(MenuHtmlPanel)
            .await(communicator.demand(Locale))
            .with(communicator)
            .then(onMessage);
    }

    function onMessage(message: MenuHtmlPanel, locale: Locale, communicator: Communicator) {
        panel = message.panel;
        for(index in 0...Type.getEnumConstructs(TopLevelGroup).length) {
            var group = new Html5MenuGroup(createDropdown('', []), []);
            groups[index] = group;
        }
        communicator.consume(onMenuItemMessages);
    }

    function onMenuItemMessages(messages: Array<MenuItem>) {
        for(message in messages) {
            addItem(message);
        }
    }

    function addItem(item: MenuItem) {
        var index = Type.enumIndex(item.group);
        var group = groups[index];
        var subIndex = TopLevelGroups.subgroupIndex(item.group);
        var subgroup = group.subgroups[subIndex];

        if(subgroup == null) {
            group.subgroups[subIndex] = [];
            var ref = panel.element.find('.dropdown:eq(${index-1})');
            if(ref.length > 0) {
                group.dropdown.element.insertAfter(ref);
            } else if(index == 0) {
                group.dropdown.element.prependTo(panel.element);
            } else {
                group.dropdown.element.appendTo(panel.element);
            }
        }

        var weightedDropdownItems = group.subgroups[subIndex];
        weightedDropdownItems.push(new WeightedDropdownItem(item.weight, DropdownButton(item.label, '', function(_) { item.callback(); })));
        weightedDropdownItems.sort(byWeight);

        group.replaceDropdown(dropdownFromGroup(TopLevelGroups.name(item.group), group));
    }

    function fromWeighted(weighted: WeightedDropdownItem) {
        return weighted.item;
    }

    function byWeight(a: WeightedDropdownItem, b: WeightedDropdownItem) {
        return a.weight - b.weight;
    }

    function dropdownFromGroup(name: String, group: Html5MenuGroup) {
        var items = [].concat(group.subgroups[0].map(fromWeighted));
        for(subgroup in group.subgroups.slice(1)) {
            items.push(DropdownDivider);
            items = items.concat(subgroup.map(fromWeighted));
        }

        return createDropdown(name, items);
    }

    function createDropdown(name: String, items: Array<DropdownItem>) {
        return new HtmlDropdown(name, '', 'btn-group', Mini, items, DropdownAlignLeft);
    }
}
