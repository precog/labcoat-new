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
package precog.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

class Catamorphism {
#if macro
    public static function build(classes: Array<String>) {
        var fields = Context.getBuildFields();
        fields.push(cataMethod(classes, null));
        return fields;
    }

    public static function autoBuild(classes: Array<String>) {
        var fields = Context.getBuildFields();
        var name = Context.getLocalClass().get().name;
        var index = Lambda.indexOf(classes, name);
        fields.push(cataMethod(classes, macro return $i{'_${index}'}($i{"this"})));
        return fields;
    }

    static function cataMethod(classes: Array<String>, body: Expr): Field {
        var types = classes.map(function(s: String) return Context.getType(s));

        var a = TPath({name: 'A', pack: [], params: []});

        var args = [];
        for(index in 0...classes.length) {
            var className = classes[index];
            args.push({
                name: '_${index}',
                type: TFunction([Context.toComplexType(types[index])], a),
                opt: false,
                value: null
            });
        }

        return {
            name: "cata",
            access: [APublic],
            pos: Context.currentPos(),
            kind: FFun({
                args: args,
                expr: body,
                params: [{name: 'A'}],
                ret: a
            })
        };
    }
#end
}
