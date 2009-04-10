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

package com.whirled.contrib.sound {

import flash.media.Sound;
import flash.system.ApplicationDomain;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

/**
 * A flash9-compatible SoundFactory that simply pulls sounds out of a provided ApplicationDomain.
 * Once sounds have been fetched from the ApplicationDomain once, they are cached in a local
 * HashMap.
 */
public class ApplicationDomainSoundFactory
    implements SoundFactory
{
    /**
     * If no ApplicationDomain is provided, ApplicationDomain.currentDomain is used
     */
    public function ApplicationDomainSoundFactory (appDom :ApplicationDomain = null)
    {
        _appDom = appDom == null ? ApplicationDomain.currentDomain : appDom;
    }

    public function getSound (name :String) :Sound
    {
        var sound :Sound = _sounds.get(name);
        if (sound == null) {
            var cls :Class = _appDom.getDefinition(name) as Class;
            sound = cls == null ? null : new cls() as Sound;
            if (sound == null) {
                log.warning("Sound not found!", "name", name);
            } else {
                _sounds.put(name, sound);
            }
        }
        return sound;
    }

    protected var _appDom :ApplicationDomain;
    protected var _sounds :HashMap = new HashMap();

    private static const log :Log = Log.getLog(ApplicationDomainSoundFactory);
}
}