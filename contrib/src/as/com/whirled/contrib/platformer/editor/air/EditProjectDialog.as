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

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.core.UIComponent;

import com.threerings.flex.CommandButton;

public class EditProjectDialog extends LightweightCenteredDialog
{
    public function EditProjectDialog (existingProject :File, callback :Function)
    {
        _existingProject = existingProject;
        _saveCallback = callback;
        if (_existingProject != null) {
            var stream :FileStream = new FileStream();
            stream.open(_existingProject, FileMode.READ);
            _projectXml = XML(stream.readUTFBytes(stream.bytesAvailable));
            stream.close();
        } else {
            _projectXml = <platformerproject/>;
        }

        width = 600;
        height = 200;
        title = (_existingProject != null ? "Edit" : "Create") + " Project";
        setStyle("backgroundColor", "white");
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // Windows use vertical layout by default, but VBox gives us some extra stuff, like padding
        var container :VBox = new VBox();
        container.percentWidth = 100;
        container.percentHeight = 100;
        setStyles(container, -1, 10);
        addChild(container);

        var pieceXmlFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null, 
            String(_projectXml.pieceXml.@path));
        var pieceSwfFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null,
            String(_projectXml.pieceSwf.@path));
        var dynamicsXmlFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null,
            String(_projectXml.dynamicsXml.@path));

        container.addChild(_pieceXmlRow = new EditorFileRow(
            "Piece XML", "xml", true, pieceXmlFile, _existingProject, this));
        container.addChild(_pieceSwfRow = new EditorFileRow(
            "Piece SWF", "swf", false, pieceSwfFile, _existingProject, this));
        container.addChild(_dynamicsXmlRow = new EditorFileRow(
            "Dynamics XML", "xml", true, dynamicsXmlFile, _existingProject, this));

        var dialogButtons :HBox = new HBox(); 
        dialogButtons.percentWidth = 100;
        setStyles(dialogButtons, 10, 5);
        var spacer :HBox = new HBox();
        spacer.percentWidth = 100;
        dialogButtons.addChild(spacer);
        dialogButtons.addChild(new CommandButton("Cancel", close));
        dialogButtons.addChild(new CommandButton("Save", handleSave));
        container.addChild(dialogButtons);
    }

    protected function setStyles (component :UIComponent, gap :int, padding :int) :void
    {
        if (gap >= 0) {
            component.setStyle("horizontalGap", gap);
        }

        if (padding >= 0) {
            component.setStyle("paddingTop", padding);
            component.setStyle("paddingBottom", padding);
            component.setStyle("paddingLeft", padding);
            component.setStyle("paddingRight", padding);
        }
    }

    public function handleSave () :void
    {
        if (_pieceXmlRow.file == null || _pieceSwfRow.file == null || 
                _dynamicsXmlRow.file == null) {
            Editor.popError("All files are required");
            return;
        }

        if (!Editor.checkFileSanity(_pieceSwfRow.file, "swf", "Piece SWF")) {
            return;
        }

        if (_pieceXmlRow.create) {
            var pieceXml :XML = <platformer>
                <pieceset/>
            </platformer>;
            var outputString :String = XML_HEADER + pieceXml.toXMLString() + '\n';
            var stream :FileStream = new FileStream();
            stream.open(_pieceXmlRow.file, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        }
        if (!Editor.checkFileSanity(_pieceXmlRow.file, "xml", "Piece XML")) {
            return;
        }

        if (_dynamicsXmlRow.create) {
            var dynamicsXml :XML = <dynamics/>;
            outputString = XML_HEADER + dynamicsXml.toXMLString() + '\n';
            stream = new FileStream();
            stream.open(_dynamicsXmlRow.file, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        }
        if (!Editor.checkFileSanity(_dynamicsXmlRow.file, "xml", "Dynamics XML")) {
            return;
        }

        if (_existingProject == null) {
            var newFile :File = 
                new File(File.desktopDirectory.nativePath + File.separator + "project.xml");
            newFile.browseForSave("Select new project file location [*.xml]");
            var saver :Function;
            saver = function (event :Event) :void {
                newFile.removeEventListener(Event.SELECT, saver);
                saveAndClose(EditorFileRow.sanitizeFilename(event.target as File));
            };
            newFile.addEventListener(Event.SELECT, saver);
            fileDialogCloseHandler(newFile);

        } else {
            saveAndClose(_existingProject);
        }
    }

    protected function saveAndClose (file :File) :void
    {
        _projectXml.pieceXml = <pieceXml/>;
        _projectXml.pieceXml.@path = findPath(file, _pieceXmlRow.file);
        _projectXml.pieceSwf = <pieceSwf/>;
        _projectXml.pieceSwf.@path = findPath(file, _pieceSwfRow.file);
        _projectXml.dynamicsXml = <dynamicsXml/>;
        _projectXml.dynamicsXml.@path = findPath(file, _dynamicsXmlRow.file);

        var outputString :String = XML_HEADER + _projectXml.toXMLString() + '\n';
        var stream :FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(outputString);
        stream.close();

        close();
        _saveCallback(file);
    }

    protected function fileDialogCloseHandler (file :File) :void
    {
        var orderer :Function;
        orderer = function (event :Event) :void {
            file.removeEventListener(Event.SELECT, orderer);
            file.removeEventListener(Event.CLOSE, orderer);
            orderToFront();
        };
        file.addEventListener(Event.SELECT, orderer);
        file.addEventListener(Event.CANCEL, orderer);
    }

    protected function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    protected var _existingProject :File;
    protected var _projectXml :XML;
    protected var _saveCallback :Function;
    protected var _pieceXmlRow :EditorFileRow;
    protected var _pieceSwfRow :EditorFileRow;
    protected var _dynamicsXmlRow :EditorFileRow;

    protected static const XML_HEADER :String = '<?xml version="1.0" encoding="utf-8"?>\n';
}
}
