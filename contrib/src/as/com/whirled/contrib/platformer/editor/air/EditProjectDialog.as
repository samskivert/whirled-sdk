// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.platformer.editor.air {

import flash.display.NativeWindowType;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.core.Window;

import com.threerings.flex.CommandButton;

import com.threerings.util.Log;

public class EditProjectDialog extends Window
{
    public function EditProjectDialog (existingProject :File = null)
    {
        _existingProject = existingProject;
        if (_existingProject != null) {
            var stream :FileStream = new FileStream();
            stream.open(_existingProject, FileMode.READ);
            _projectXML = XML(stream.readUTFBytes(stream.bytesAvailable));
            stream.close();
        } else {
            _projectXML = <platformerproject/>;
        }

        width = 500;
        height = 200;
        maximizable = false;
        minimizable = false;
        type = NativeWindowType.UTILITY;
        title = (existingProject != null ? "Edit" : "Create") + " Project";
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // Windows use vertical layout by default, but VBox gives us some extra stuff, like padding
        var container :VBox = new VBox();
        container.percentWidth = 100;
        container.percentHeight = 100;
        addChild(container);

        var dialogButtons :HBox = new HBox(); 
        dialogButtons.percentWidth = 100;
        dialogButtons.setStyle("horizontalGap", 20);
        var spacer :HBox = new HBox();
        spacer.percentWidth = 100;
        dialogButtons.addChild(spacer);
        dialogButtons.addChild(new CommandButton("Cancel", close));
        dialogButtons.addChild(new CommandButton("Save", handleSave));
        container.addChild(dialogButtons);
    }

    public function handleSave () :void
    {
        if (_existingProject == null) {
            var newFile :File = 
                new File(File.desktopDirectory.nativePath + File.separator + "project.xml");
            newFile.browseForSave("Select new project file location [*.xml]");
            newFile.addEventListener(Event.SELECT, function (event :Event) :void {
                saveAndClose(sanitizeFilename(event.target as File));
            });

        } else {
            saveAndClose(_existingProject);
        }
    }

    protected function saveAndClose (file :File) :void
    {
        var outputString :String = '<?xml version="1.0" encoding="utf-8"?>\n';
        outputString += _projectXML.toXMLString() + '\n';
        var stream :FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(outputString);
        stream.close();
        close();
    }

    /**
     * I can't believe how much Adobe fails at life.  AIR lets you filter file selection by 
     * extension on file selection for open and file selection for upload... but not file selection
     * for save.
     */
    protected function sanitizeFilename (file :File) :File
    {
        var pathRegExp :RegExp = 
            new RegExp("^(.*" + File.separator + ")([^" + File.separator + "]+)$");
        var filePath :String = file.nativePath.replace(pathRegExp, "$1");
        var fileName :String = file.nativePath.replace(pathRegExp, "$2"); 
        fileName = fileName.indexOf(".") < 0 ? fileName : fileName.replace(/^(.*)\.[^\.]*$/, "$1");
        return new File(filePath + fileName + ".xml");
    }

    protected var _existingProject :File;
    protected var _projectXML :XML;
}
}
