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

@:remove @:autoBuild(precog.macro.ValueClassImpl.build())
extern interface ValueClass {}

class ValueClassImpl {
#if macro
    public static function build() {
        var fields = Context.getBuildFields();
        var args = [];
        var states = [],
            tostring = [];
        for (f in fields) {
            switch (f.kind) {
            case FVar(t, _):
                args.push({name: f.name, type: t, opt: false, value: null});
                states.push(macro $p{["this", f.name]} = $i{f.name});
                tostring.push(macro __b.push($v{f.name} + " : " + $p{["this", f.name]}));
                f.kind = FProp("default", "null", t);
                f.access.push(APublic);
            default:
            }
        }
        fields.push({
            name: "new",
            access: [APublic],
            pos: Context.currentPos(),
            kind: FFun({
                args: args,
                expr: macro $b{states},
                params: [],
                ret: null
            })
        });

        var type = Context.getLocalClass().toString().split('.').pop();
        fields.push({
            name: "toString",
            access: [APublic],
            pos: Context.currentPos(),
            kind: FFun({
                args: [],
                expr: macro {
                    var __b = [];
                    $b{tostring};
                    return $v{type} + (__b.length == 0 ? "" : " {" + __b.join(",") + "}");
                },
                params: [],
                ret: TPath({ pack : [], name : "String", params : [], sub : null })
            })
        });
        return fields;
    }
#end
}
