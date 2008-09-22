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

package com.whirled.contrib.platformer.display {

import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicSpriteLayer extends Layer
{
    public function addDynamicSprite (ds :DynamicSprite) :void
    {
        _dynamics.push(ds);
        addChild(ds);
    }

    public function removeDynamicSprite (d :Dynamic) :void
    {
        for (var ii :int = 0; ii < _dynamics.length; ii++) {
            if (_dynamics[ii].getDynamic() == d) {
                if (_dynamics[ii].parent == this) {
                    removeChild(_dynamics[ii]);
                }
                _dynamics.splice(ii, 1);
                break;
            }
        }
    }

    public function updateSprites (delta :Number) :void
    {
        for each (var ds :DynamicSprite in _dynamics) {
            ds.update(delta);
        }
    }

    protected var _dynamics :Array = new Array();
}
}