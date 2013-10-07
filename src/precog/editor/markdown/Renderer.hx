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
package precog.editor.markdown;

enum MarkdownContentTag {
    MarkdownP;
    MarkdownA;
    MarkdownUL;
    MarkdownLI;
    MarkdownH1;
    MarkdownH2;
}

enum MarkdownEmptyTag {
    MarkdownIMG;
}

enum MarkdownNode {
    MarkdownContentElement(tag: MarkdownContentTag, content: Array<MarkdownNode>, attributes: Map<String, String>);
    MarkdownEmptyElement(tag: MarkdownEmptyTag, attributes: Map<String, String>);
    MarkdownText(text: String);
}

class Renderer {
    public static function render(ast: Array<MarkdownNode>) {
        return ast.map(renderNode).join('\n');
    }

    static function renderNode(node: MarkdownNode) {
        return switch(node) {
        case MarkdownContentElement(tag, content, attributes):
            var tagName = contentTagString(tag);
            var inner = content.map(renderNode).join('\n');
            '<${tagName}${attributesString(attributes)}>${inner}</${tagName}>';
        case MarkdownEmptyElement(tag, attributes):
            var tagName = emptyTagString(tag);
            '<${tagName}${attributesString(attributes)} />';
        case MarkdownText(text):
            '${text}';
        };
    }

    static function attributesString(attributes: Map<String, String>) {
        var accum = '';
        for(key in attributes.keys()) {
            accum += ' ${key}="${attributes.get(key)}"';
        }
        return accum;
    }

    static function contentTagString(tag: MarkdownContentTag) {
        return switch(tag) {
        case MarkdownP: 'p';
        case MarkdownA: 'a';
        case MarkdownUL: 'ul';
        case MarkdownLI: 'li';
        case MarkdownH1: 'h1';
        case MarkdownH2: 'h2';
        }
    }

    static function emptyTagString(tag: MarkdownEmptyTag) {
        return switch(tag) {
        case MarkdownIMG: 'img';
        }
    }
}
