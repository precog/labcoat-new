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
package labcoat.message;

import precog.macro.ValueClass;

class MenuItem implements ValueClass {
    var group: TopLevelGroup;
    var label: String;
    var callback: Void -> Void;
    var weight: Int;
}

enum TopLevelGroup {
    MenuFile(subgroup: SubgroupFile);
    MenuEdit(subgroup: SubgroupEdit);
    MenuFind(subgroup: SubgroupFind);
    MenuView(subgroup: SubgroupView);
    MenuCode(subgroup: SubgroupCode);
    MenuCollaborate(subgroup: SubgroupCollaborate);
    MenuHelp(subgroup: SubgroupHelp);
}

enum SubgroupFile {
    SubgroupFileLocal;
    SubgroupFileImportExport;
    SubgroupFileSave;
}

enum SubgroupEdit {
    SubgroupEditHistory;
}

enum SubgroupFind {
}

enum SubgroupView {
}

enum SubgroupCode {
    SubgroupCodeVariables;
    SubgroupCodeComments;
    SubgroupCodeDeclarations;
    SubgroupCodeFormating;
    SubgroupCodeInsert;
    SubgroupCodeRun;
}

enum SubgroupCollaborate {
    SubgroupCollaborateChannels;
    SubgroupCollaborateSharing;
    SubgroupCollaborateComments;
}

enum SubgroupHelp {
    SubgroupHelpLookup;
    SubgroupHelpQuirrel;
    SubgroupHelpSupport;
}


class TopLevelGroups {
    public static function name(group: TopLevelGroup) {
        return switch(group) {
        case MenuFile(_): 'File';
        case MenuEdit(_): 'Edit';
        case MenuFind(_): 'Find';
        case MenuView(_): 'View';
        case MenuCode(_): 'Code';
        case MenuCollaborate(_): 'Collaborate';
        case MenuHelp(_): 'Help';
        }
    }

    // This is awful. Haxe's fault.
    public static function subgroupIndex(group: TopLevelGroup) {
        var value: EnumValue = switch(group) {
        case MenuFile(subgroup): subgroup;
        case MenuEdit(subgroup): subgroup;
        case MenuFind(subgroup): subgroup;
        case MenuView(subgroup): subgroup;
        case MenuCode(subgroup): subgroup;
        case MenuCollaborate(subgroup): subgroup;
        case MenuHelp(subgroup): subgroup;
        }
        return Type.enumIndex(value);
    }

    public static function isHidden(group: TopLevelGroup, platform: String) {
        if(platform == "darwin") {
            return switch(group) {
            case MenuEdit(_): true;
            case _: false;
            }
        }
        return false;
    }
}
