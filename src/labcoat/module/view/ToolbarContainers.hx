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

import labcoat.config.ViewConfig;
import precog.html.HtmlPanel;
import precog.html.HtmlPanelGroup;
import precog.layout.DockLayout;

using thx.react.IObservable;

class ToolbarContainers {
    public var toolbar(default, null): HtmlPanel;
    public var main(default, null): HtmlPanel;

    public function new(group : HtmlPanelGroupItem, ?toolbarHeight : Int, ?margin : Int) {
        toolbar = new HtmlPanel();
        main = new HtmlPanel();

        toolbarHeight = null != toolbarHeight ? toolbarHeight : ViewConfig.toolbarHeight;
        margin = null != margin ? margin : ViewConfig.panelMargin;

        var layout = new DockLayout(group.panel.rectangle.width, group.panel.rectangle.height);
        layout.defaultMargin = margin;
        group.panel.rectangle.addListener(function(r) {
            layout.rectangle.updateSize(r); //updateSize
            layout.update();
        });

        group.panel.element.append(toolbar.element);
        group.panel.element.append(main.element);

        layout.addPanel(toolbar).dockTop(toolbarHeight);
        layout.addPanel(main);
        layout.update();
    }
}


/*
    public function new(group : HtmlPanelGroupItem, ?toolbarHeight : Float, ?margin : Float) {
        toolbar = new HtmlPanel();
        main = new HtmlPanel();

        toolbarHeight = null != toolbarHeight ? toolbarHeight : ViewConfig.toolbarHeight;
        margin = null != margin ? margin : ViewConfig.panelMargin;

        var layout = new DockLayout(group.panel.rectangle.width, group.panel.rectangle.height);
        layout.defaultMargin = margin;
        group.panel.rectangle.addListener(function(r) {
            layout.rectangle.updateSize(r); //updateSize
            layout.update();
        });

        group.panel.element.append(toolbar.element);
        group.panel.element.append(main.element);

        layout.addPanel(toolbar).dockTop(toolbarHeight);
        layout.addPanel(main);
        layout.update();
    }
}


*/