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

import utest.Assert;

class TestRenderer {
    public function new() { }

    public function testRenderText() {
        Assert.equals(
            Renderer.render([MarkdownText('Hello world'), MarkdownText('World')]),
            'Hello world\nWorld'
        );
    }

    public function testRenderHeader() {
        Assert.equals(
            Renderer.render([MarkdownContentElement(MarkdownH1, [MarkdownText('Header!')], new Map())]),
            '<h1>Header!</h1>'
        );
    }

    public function testRenderImage() {
        var attributes = new Map();
        attributes.set("src", "test.jpg");
        attributes.set("alt", "");

        // Test might be relying on unspecified object iteration.
        Assert.equals(
            Renderer.render([MarkdownEmptyElement(MarkdownIMG, attributes)]),
            '<img src="test.jpg" alt="" />'
        );
    }

    public function testRenderElementWithText() {
        Assert.equals(
            Renderer.render([MarkdownContentElement(MarkdownP, [MarkdownText("Hello")], new Map()), MarkdownContentElement(MarkdownH1, [MarkdownText("World!")], new Map())]),
            '<p>Hello</p>\n<h1>World!</h1>'
        );
    }
}
