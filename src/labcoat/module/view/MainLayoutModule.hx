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

import labcoat.message.MainHtmlPanel;
import labcoat.message.MainEditorHtmlPanel;
import labcoat.message.MainStatusbarHtmlPanel;
import precog.communicator.Communicator;
import precog.communicator.Module;
import precog.html.HtmlPanel;
import precog.geom.IRectangle;
import precog.layout.DockLayout;
import js.Browser;
import jQuery.JQuery;
using thx.react.IObservable;

using precog.html.JQuerys;
import labcoat.config.ViewConfig;

class MainLayoutModule extends Module {
    var communicator: Communicator;

    var container: JQuery;

    var layout: DockLayout;
    var panelMargin: Int = 3;

    var editor: HtmlPanel;
    var statusbar: HtmlPanel;

    override public function connect(communicator: Communicator) {
        this.communicator = communicator;
        communicator.demand(MainHtmlPanel).then(onMessage);
    }

    function onMessage(message: MainHtmlPanel) {
        container = message.panel.element;

        editor    = new HtmlPanel("editor", container);
        statusbar = new HtmlPanel("statusbar", container);

        layout = new DockLayout(0, 0);
        layout.defaultMargin = panelMargin;

        layout.addPanel(editor).fill();
        layout.addPanel(statusbar).dockBottom(ViewConfig.statusbarHeight);

        message.panel.rectangle.addListener(updateLayout);
        updateLayout(message.panel.rectangle);

        communicator.provide(new MainEditorHtmlPanel(editor));
        communicator.provide(new MainStatusbarHtmlPanel(statusbar));
    }

    function updateLayout(size : IRectangle) {
        layout.rectangle.updateSize(size);
        layout.update();
    }
}
