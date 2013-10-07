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
package precog.nodewebkit;

@:native("process") extern class Process {
    static var platform: String;
}

typedef MenuItemConfig = {
    ?type: String,
    ?label: String,
    ?click: Void -> Void,
    ?submenu: Menu
};

extern class MenuItem {
    var label: String;
    var type: String;
}

class MenuItemFactory {
    public static function createEmpty(): MenuItem untyped {
        var gui = require('nw.gui');
        return untyped __js__("new gui.MenuItem()");
    }
    public static function create(options: MenuItemConfig): MenuItem untyped {
        var gui = require('nw.gui');
        return untyped __js__("new gui.MenuItem(options)");
    }
}

extern class Menu {
    var items: Array<MenuItem>;

    function append(item: MenuItem): Void;
    function remove(item: MenuItem): Void;
    function insert(item: MenuItem, index: Int): Void;
    function removeAt(index: Int): Void;
    function popup(x: Int, y: Int): Void;
}

typedef MenuConfig = {
    ?type: String
};

class MenuFactory {
    public static function createEmpty(): Menu untyped {
        var gui = require('nw.gui');
        return untyped __js__("new gui.Menu()");
    }
    public static function create(options: MenuConfig): Menu untyped {
        var gui = require('nw.gui');
        return untyped __js__("new gui.Menu(options)");
    }
}

extern class Window {
    var menu: Menu;
}

class GUI {
    public static function getWindow(): Window untyped {
        var gui = require('nw.gui');
        return gui.Window.get();
    }
}
