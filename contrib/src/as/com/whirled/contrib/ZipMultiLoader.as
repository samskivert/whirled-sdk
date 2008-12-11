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

package com.whirled.contrib {

import flash.events.Event;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import flash.system.ApplicationDomain;

import flash.utils.ByteArray;

import com.threerings.util.MultiLoader;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Utility class for MultiLoading all the files contained in a zip.
 */
public class ZipMultiLoader
{
    public function ZipMultiLoader (
        source :Object, completeCallback :Function, appDom :ApplicationDomain = null)
    {
        if (source is String) {
            source = new URLRequest(String(source));
        } else if (source is Class) {
            source = new (source as Class)();
        }
        var req :URLRequest = null;
        var bytes :ByteArray;
        if (source is URLRequest) {
            req = URLRequest(source);
        } else if (source is ByteArray) {
            bytes = ByteArray(source);
        } else {
            throw new TypeError("Expected a String or ByteArray");
        }

        _completeCallback = completeCallback;
        _appDom = appDom;

        if (req != null) {
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.load(req);
            new MultiLoader(_loader, loaderLoaded);

        } else {
            bytesAvailable(bytes);
        }
    }

    public function getLoadPercent () :int
    {
        if (_loader == null || _loader.bytesTotal == 0) {
            return 0;
        }
        return _loader.bytesLoaded * 100 / _loader.bytesTotal;
    }

    /**
     * Handle the successful completion of datapack loading.
     */
    protected function loaderLoaded (result :Object) :void
    {
        if (result is Error) {
            _completeCallback(result);

        } else {
            bytesAvailable(ByteArray(URLLoader(result).data));
        }
    }

    /**
     * Read the zip file.
     *
     * @private
     */
    protected function bytesAvailable (bytes :ByteArray) :void
    {
        bytes.position = 0;
        var zip :ZipFile;
        try {
            zip = new ZipFile(bytes);
        } catch (zipError :ZipError) {
            _completeCallback(zipError);
            return;
        }

        var sources :Array = zip.entries.map(function (entry :ZipEntry, ... rest) :ByteArray {
            return zip.getInput(entry);
        });
        MultiLoader.getLoaders(sources, _completeCallback, false, _appDom);
    }

    protected var _completeCallback :Function;
    protected var _appDom :ApplicationDomain;
    protected var _loader :URLLoader;
}
}
