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

import labcoat.message.MenuItemMessage;
import labcoat.module.view.nodewebkit.Externs;
import precog.communicator.Communicator;
import precog.communicator.Module;
import precog.macro.ValueClass;
import precog.util.Locale;

typedef NWMenuItem = labcoat.module.view.nodewebkit.MenuItem;
typedef MenuItem = labcoat.message.MenuItem;
typedef Subgroup = Array<WeightedMenuItem>;
typedef Group = Array<Subgroup>;

class WeightedMenuItem implements ValueClass {
    var weight: Int;
    var item: MenuItem;
}

class NodeWebkitMenuModule extends Module {
    var window: Window;
    var groups: Array<Group>;

    public function new() {
        super();
        window = GUI.getWindow();
        groups = [];
    }

    override public function connect(communicator: Communicator) {
        communicator
            .demand(Locale)
            .with(communicator)
            .then(onMessage);
    }

    function onMessage(locale: Locale, communicator: Communicator) {
        communicator.consume(onMenuItemMessages);
    }

    function onMenuItemMessages(messages: Array<MenuItemMessage>) {
        for(message in messages) {
            addItem(message.value);
        }
    }

    function addItem(item: MenuItem) {
        if(TopLevelGroups.isHidden(item.group, Process.platform)) return;

        var index = Type.enumIndex(item.group);
        var group = groups[index];

        if(group == null) group = groups[index] = [];

        var subIndex = TopLevelGroups.subgroupIndex(item.group);
        var subgroup = group[subIndex];

        if(subgroup == null) group[subIndex] = [];

        var weightedMenuItems = group[subIndex];
        weightedMenuItems.push(new WeightedMenuItem(item.weight, item));
        weightedMenuItems.sort(byWeight);

        // HACK: Recreate all the groups!

        // node-webkit on Mac gives us incorrect indexes for existing
        // items - only way to add items after the menu is created is
        // to recreate all groups :(
        recreateMenubar();
    }

    function recreateMenubar() {
        var menubar = MenuFactory.create({type: 'menubar'});

        // Hack: Help must be added after we set window.menu; That
        // makes it appear after the automatically inserted "Window"
        // menu.
        for(group in groups.slice(0, -1)) appendSubgroup(menubar, group);
        window.menu = menubar;
        appendSubgroup(menubar, groups[groups.length - 1]);
    }

    function appendSubgroup(menubar: Menu, group: Group) {
        if(group == null || group.length == 0 || group[0].length == 0) return;

        var name = TopLevelGroups.name(group[0][0].item.group);
        var submenu = menuFromGroup(name, group);
        menubar.append(submenu);
    }

    function fromWeighted(weighted: WeightedMenuItem) {
        return weighted.item;
    }

    function byWeight(a: WeightedMenuItem, b: WeightedMenuItem) {
        return a.weight - b.weight;
    }

    function menuFromGroup(name: String, group: Group) {
        var submenu = MenuFactory.createEmpty();

        addSubgroup(group[0], submenu);
        for(subgroup in group.slice(1)) {
            submenu.append(MenuItemFactory.create({type: 'separator'}));
            addSubgroup(subgroup, submenu);
        }

        return MenuItemFactory.create({label: name, submenu: submenu});
    }

    function addSubgroup(items: Array<WeightedMenuItem>, menu: Menu) {
        for(item in items.map(fromWeighted)) {
            menu.append(MenuItemFactory.create({label: item.label, click: item.callback}));
        }
    }
}
