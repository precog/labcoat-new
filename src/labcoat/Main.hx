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
package labcoat;

import precog.communicator.ModuleManager;

import precog.module.api.*;
import precog.module.config.*;
import precog.module.model.*;

import labcoat.module.api.*;
import labcoat.module.config.*;
import labcoat.module.model.*;
import labcoat.module.view.*;


import precog.editor.*;
import js.Browser.window;

class Main 
{
    static function main()
    {
        var manager = new ModuleManager();

        // Config
        manager.addModule(new LocalizationAdvisorModule());
        manager.addModule(new LocalizationModule());
        manager.addModule(new LogModule());

        manager.addModule(new JavascriptErrorInterceptModule());

        // View
        manager.addModule(new LoginModule());
/*
#if (html5 || cordova)
        manager.addModule(new Html5MenuModule());
#else
        manager.addModule(new NodeWebkitMenuModule());
#end
*/
        manager.addModule(new CollaborateMenuModule());
        manager.addModule(new HelpMenuModule());
        manager.addModule(new StatusModule());

        manager.addModule(new ContainerModule());
        manager.addModule(new LayoutModule());
        manager.addModule(new MainLayoutModule());

        manager.addModule(new TreeViewModule());

        manager.addModule(new labcoat.module.view.fstreeview.ActionsModule());
/* NOT IMPLEMENTED PANELS
        manager.addModule(new TutorialModule());
        manager.addModule(new ReferenceModule());
        manager.addModule(new ExamplesModule());
        manager.addModule(new NotesModule());

        manager.addModule(new TasksModule());
        manager.addModule(new SharingModule());
        manager.addModule(new ChatModule());
*/
        manager.addModule(new EditorModule());
        manager.addModule(new StatusbarModule());

        // Model
        manager.addModule(new PrecogAuthModule());
        manager.addModule(new PrecogModule());
        manager.addModule(new FileSystemModule());

        // API
        manager.addModule(new JavaScriptAPIModule());
        manager.addModule(new VersionModule());
    }
}