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
package precog.editor.codemirror;

import precog.editor.codemirror.Externs;
import precog.editor.Macros.jsRegExp;

class QuirrelMode {
    static var punctuation = jsRegExp(~/([([{]|[)}\]]|,)/);
    static var keywords = jsRegExp(~/(difference|else|solve|if|import|intersect|new|then|union|where|with)\b/);
    static var constants = jsRegExp(~/(true|false|undefined|null)\b/);
    static var functions = jsRegExp(~/(count|distinct|load|max|mean|geometricMean|sumSq|variance|median|min|mode|stdDev|sum)\b/);
    static var operators = jsRegExp(~/(~|:=|\+|\/|\-|\*|&|\||<|>|<=|=>|!=|<>|=|!|neg|union\b)/);
    static var lineComment = jsRegExp(~/--.*$/);
    static var commentStart = jsRegExp(~/\(-/);
    static var commentEnd = jsRegExp(~/.*?-\)/);
    static var numeric = jsRegExp(~/[0-9]+(?:\\.[0-9]+)?(?:[eE][0-9]+)?/);
    static var path = jsRegExp(~/\/(?:\/[a-zA-Z_0-9-]+)+\b/);
    static var variable = jsRegExp(~/['][A-Za-z][A-Za-z_0-9]*/);
    static var string = jsRegExp(~/"(?:\\"|[^"])*"/);
    static var identifier = jsRegExp(~/[A-Za-z_][A-Za-z0-9_']*/);

    public static function init() {
        CodeMirror.defineMode("quirrel", mode);
    }

    static function mode(config: Config, parserConfig: ParserConfig) {
        return {startState: startState, token: token};
    }

    static function startState() {
        return {inComment: false};
    }

    static function token(stream: StringStream, state: {inComment: Bool}) {
        if(state.inComment) {
            if(stream.match(commentEnd) != null) {
                state.inComment = false;
                return "comment";
            }
            stream.skipToEnd();
            return "comment";
        } else if(stream.match(commentStart) != null) {
            state.inComment = true;
            return "comment";
        }

        stream.eatSpace();
        if(stream.sol() && stream.match(lineComment) != null) {
            return "comment";
        } else if(stream.match(string) != null) {
            return "string";
        } else if(stream.match(path) != null) {
            return "string";
        } else if(stream.match(keywords) != null) {
            return "keyword";
        } else if(stream.match(operators) != null) {
            return "operator";
        } else if(stream.match(constants) != null || stream.match(functions) != null) {
            return "builtin";
        } else if(stream.match(numeric) != null) {
            return "number";
        } else if(stream.match(variable) != null) {
            return "string";
        } else if(stream.match(identifier) != null) {
            return "identifier";
        } else if(stream.match(punctuation) != null) {
            return null;
        }
        stream.skipToEnd();
        return null;
    }
}
