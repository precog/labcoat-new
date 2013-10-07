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
package precog.fs;

import utest.Assert;
import precog.fs.FileSystem;

class TestFileSystem 
{
	public function new() { }

	var fs : FileSystem;
	public function setup()
	{
		fs = new FileSystem();
	}

	public function testAddRemoveFile()
	{
		var file = new File("sample", fs.root);
		Assert.equals(file, fs.root.files.list()[0]);
		fs.root.removeNode(file);
		Assert.equals(0, fs.root.files.length);
	}

	public function testAddRemoveDirectory()
	{
		var dir = new Directory("sample", fs.root);
		Assert.equals(dir, fs.root.directories.list()[0]);
		fs.root.removeNode(dir);
		Assert.equals(0, fs.root.directories.length);
	}

	public function testPath()
	{
		var dir = new Directory("dir", fs.root),
			file = new File("file.ext", dir);
		Assert.equals("/", fs.root.toString());
		Assert.equals("/dir", dir.toString());
		Assert.equals("/dir/file.ext", file.toString());
	}

	public function testCount()
	{
		Assert.equals(0, fs.root.length);
		Assert.equals(0, fs.root.directories.length);
		Assert.equals(0, fs.root.files.length);
		// count directories
		new Directory("dir", fs.root);
		Assert.equals(1, fs.root.length);
		Assert.equals(1, fs.root.directories.length);
		Assert.equals(0, fs.root.files.length);
		// count files
		new File("file.ext", fs.root);
		Assert.equals(2, fs.root.length);
		Assert.equals(1, fs.root.directories.length);
		Assert.equals(1, fs.root.files.length);
	}

	public function testPathWithSlash()
	{
		var dir = new Directory("di/r", fs.root),
			file = new File("fil/e.ext", dir);
		Assert.equals("/", fs.root.toString());
		Assert.equals("/di\\/r", dir.toString());
		Assert.equals("/di\\/r/fil\\/e.ext", file.toString());

	}

	public function testMoveNodeInTheSameFilesystem()
	{
		var dir1 = new Directory("dir1", fs.root),
			dir2 = new Directory("dir2", fs.root),
			file = new File("file.ext", dir1);
		Assert.equals("/dir1/file.ext", file.toString());
		dir2.addNode(file);
		Assert.equals("/dir2/file.ext", file.toString());
		Assert.equals(0, dir1.files.length);
		Assert.equals(1, dir2.files.length);
	}

	public function testMoveNodeToAnotherSameFilesystem()
	{
		var file = new File("file.ext", fs.root);
		Assert.equals(1, fs.root.files.length);
		Assert.equals(fs, file.filesystem);
		Assert.equals(fs.root, file.parent);

		var fs2 = new FileSystem();
		fs2.root.addNode(file);
		Assert.equals(fs2, file.filesystem);
		Assert.equals(fs2.root, file.parent);
		Assert.equals(0, fs.root.files.length);
		Assert.equals(1, fs2.root.files.length);
	}

	public function testRename()
	{
		var file = new File("file.ext", fs.root);
		Assert.equals("file.ext", file.name);
		file.name = "other.ext";
		Assert.equals("other.ext", file.name);
		Assert.equals("/other.ext", file.toString());
	}

	public function testExtension()
	{
		var file = new File("fil.e.ext", fs.root);
		Assert.equals("fil.e", file.baseName);
		Assert.equals("ext", file.extension);
		file.extension = "png";
		Assert.equals("fil.e.png", file.name);
		file.baseName = "file";
		Assert.equals("file.png", file.name);
	}

	public function testMetadata()
	{
		var file = new File("file.ext", fs.root);
		Assert.isFalse(file.meta.exists("key"));
		file.meta.set("key", 1);
		Assert.isTrue(file.meta.exists("key"));
		Assert.equals(1, file.meta.get("key"));
		Assert.isTrue(file.meta.keys().hasNext());
		Assert.isTrue(file.meta.iterator().hasNext());
		file.meta.remove("key");
		Assert.isFalse(file.meta.keys().hasNext());
		Assert.isFalse(file.meta.iterator().hasNext());
		var m = new Map<String, Dynamic>();
		m.set("key", 1);
		file.meta.setMap(m);
		Assert.equals(1, file.meta.get("key"));
		file.meta.setObject({key2:2});
		Assert.equals(2, file.meta.get("key2"));
	}

	public function testNameValidation()
	{
		Assert.raises(function()
			new File(null, fs.root)
		);
		Assert.raises(function()
			new File("", fs.root)
		);
	}

	function createTree()
	{
		var a = new Directory("a", fs.root),
			b = new Directory("b", fs.root),
			c = new Directory("c", a);
		return {
			a : a,
			b : b,
			c : c,
			AAA : new File("AAA.ext", fs.root),
			ABA : new File("ABA.ext", fs.root),
			ABC : new File("ABC.ext", b),
			G : new File("G.png", c)
		};
	}

	public function testFindFromDirectory()
	{
		var tree = createTree();

		Assert.equals(2 , fs.root.find(~/\.ext$/).length);
		Assert.equals(4 , fs.root.find(~/.+/).length);
		Assert.equals(3 , fs.root.find(~/a/i).length);

		Assert.equals(2 , fs.root.files.find(~/.+/).length);
		Assert.equals(1 , fs.root.files.find(~/b/i).length);

		Assert.equals(2 , fs.root.directories.find(~/.+/).length);
		Assert.equals(1 , fs.root.directories.find(~/a/i).length);

		// traverse
		Assert.equals(1, tree.c.traverse(["..", "..", ".", "b", "|bc|i"]).length);
		Assert.equals(1, tree.c.traverse("../.././b/|bc|i").length);
	}

	public function testPick()
	{
		var tree = createTree();
		Assert.equals(tree.ABC, tree.c.pick("../.././b/|bc|i"));
		Assert.equals(tree.c, tree.c.pick("../.././a/|^C$|i"));
	}

	public function testEnsureDirectory()
	{
		var a = new Directory("a", fs.root);
		var b = fs.root.ensureDirectory("a/b");
		Assert.is(b, Directory);
		Assert.equals(a, b.parent);
		var c = b.ensureDirectory("/a/c");
		Assert.equals(a, c.parent);
		var d = b.ensureDirectory("../d");
		Assert.equals(a, d.parent);
	}

	public function testCreateFileAt()
	{
		var a = new Directory("a", fs.root);
		var b = fs.root.createFileAt("a/b");
		Assert.is(b, File);
		Assert.equals(a, b.parent);
		Assert.raises(function() {
			a.createFileAt("/b/c");
		});
		var c = a.createFileAt("/b/c", true);
		Assert.notEquals(fs.root, c.parent);
		
	}

	public function testRemove()
	{
		var tree = createTree();
		Assert.raises(function()
			tree.a.remove()
		);
		Assert.equals(1, fs.root.find("a").length);
		tree.a.removeRecursive();
		Assert.equals(0, fs.root.find("a").length);
	}

	public function testRemoveAt()
	{
		var tree = createTree();
		Assert.raises(function()
			fs.root.removeAt("/a")
		);
		Assert.equals(1, fs.root.find("a").length);
		fs.root.removeAt("/a", true);
		Assert.equals(0, fs.root.find("a").length);
	}

	public function testDuplicatedFileAndDirectory()
	{
		new Directory("a", fs.root);
		Assert.raises(function()
			new Directory("a", fs.root)
		);
	}
	public function testObserveName()
	{
		var file = new File("a", fs.root);
		fs.on(function(event : NodeNameEvent) {
			Assert.equals("a", event.oldname);
			Assert.equals("b", event.newname);
			Assert.equals(file, event.node);
		});
		file.name = "b";
	}

	public function testObserveAddRemove()
	{
		var added = false,
			removed = false;
		fs.on(function(event : NodeAddEvent) {
			added = true;
			Assert.is(event.node, File);
		});

		fs.on(function(event : NodeRemoveEvent) {
			removed = true;
			Assert.equals(fs.root, event.parent);
			Assert.is(event.node, File);
		});

		var file = new File("a", fs.root);
		Assert.isTrue(added);
		Assert.isFalse(removed);

		file.remove();
		Assert.isTrue(removed);
	}

	public function testObserveMetadata()
	{
		var file = new File("a", fs.root);
		fs.on(function(event : MetaChangeEvent) {
			Assert.equals(file, event.node);
			Assert.isNull(event.oldvalue);
			Assert.equals(1, event.newvalue);
			Assert.equals("k", event.key);
		});
		file.meta.set("k", 1);
	}
}