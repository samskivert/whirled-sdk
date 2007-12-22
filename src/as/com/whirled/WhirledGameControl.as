//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import com.threerings.ezgame.AbstractGameControl;
import com.threerings.ezgame.EZLocalSubControl;
import com.threerings.ezgame.EZNetSubControl;
import com.threerings.ezgame.EZPlayerSubControl;
import com.threerings.ezgame.EZGameSubControl;
import com.threerings.ezgame.EZServicesSubControl;

/**
 * The primary class used to coordinate game state and control your multiplayer game.
 *
 * Typically, you create this in your top-level MovieClip/Sprite:
 * var _ctrl :WhirledGameControl;
 * _ctrl = new WhirledGameControl(this);
 */
public class WhirledGameControl extends AbstractGameControl
{
    /**
     * Creates a control and connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.threerings.ezgame.EZGameControl#playerReady()
     */
    public function WhirledGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, autoReady);
    }

    /**
     * Access the 'local' services.
     */
    public function get local () :LocalSubControl
    {
        return _localCtrl as LocalSubControl;
    }

    /**
     * Access the 'net' services.
     */
    public function get net () :EZNetSubControl
    {
        return _netCtrl;
    }

    /**
     * Access the 'player' services.
     */
    public function get player () :PlayerSubControl
    {
        return _playerCtrl as PlayerSubControl;
    }

    /**
     * Access the 'game' services.
     */
    public function get game () :GameSubControl
    {
        return _gameCtrl as GameSubControl;
    }

    /**
     * Access the 'services' services.
     */
    public function get services () :EZServicesSubControl
    {
        return _servicesCtrl;
    }

    override protected function createLocalControl () :EZLocalSubControl
    {
        return new LocalSubControl(this);
    }

    override protected function createPlayerControl () :EZPlayerSubControl
    {
        return new PlayerSubControl(this);
    }

    override protected function createGameControl () :EZGameSubControl
    {
        return new GameSubControl(this);
    }
}
}
