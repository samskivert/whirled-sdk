//
// $Id$

package com.whirled.client {

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.flex.CommandButton;

import com.threerings.parlor.game.data.GameConfig;

import com.threerings.ezgame.client.EZGamePanel;
import com.threerings.ezgame.data.EZGameConfig;

public class WhirledGamePanel extends EZGamePanel
{
    public function WhirledGamePanel (ctx :CrowdContext, ctrl: WhirledGameController)
    {
        super(ctx, ctrl);

        var labels :Array = getButtonLabels();
        _backToLobby = new CommandButton();
        _backToLobby.label = labels[0];
        _backToWhirled = new CommandButton();
        _backToWhirled.label = labels[1];
        _rematch = new CommandButton();
        _rematch.toggle = true;
        _rematch.label = labels[2];
        _rematch.setCallback(handleRematchClicked);
    }

    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        // Important: we need to start the playerList prior to calling super, so that it
        // is added as a listener to the gameObject prior to the backend being created
        // and added as a listener. That way, when the ezgame hears about an occupantAdded
        // event, the playerList already knows about that player!
        _playerList.startup(plobj);

        super.willEnterPlace(plobj);

        _backToWhirled.setCallback((_ctrl as WhirledGameController).backToWhirled, false);
        _backToLobby.setCallback((_ctrl as WhirledGameController).backToWhirled, true);
        checkRematchVisibility();
    }

    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _playerList.shutdown();

        super.didLeavePlace(plobj);
    }

    /**
     * Get a handle on the player list.
     */
    public function getPlayerList () :PlayerList
    {
        return _playerList;
    }

    /**
     * Set whether or not we show some of the standard buttons.
     */
    public function setShowButtons (
        rematch :Boolean, backToLobby :Boolean, backToWhirled :Boolean) :void
    {
        _showRematch = rematch;
        checkRematchVisibility();
        _backToLobby.visible = backToLobby;
        _backToLobby.includeInLayout = backToLobby;
        _backToWhirled.visible = backToWhirled;
        _backToWhirled.includeInLayout = backToWhirled;
    }

    /**
     * Called by the controller and internally to update the visibility of the rematch button.
     */
    public function checkRematchVisibility () :void
    {
        // only show the rematch button if it's been configured to be on, the game is over,
        // has been in a round before, and we're NOT a party game
        var canRematch :Boolean = _showRematch && !_ezObj.isInPlay() && (_ezObj.roundId != 0) &&
            ((_ctrl.getPlaceConfig() as EZGameConfig).getMatchType() != GameConfig.PARTY) &&
            (_ezObj.getPlayerCount() == _ezObj.getActivePlayerCount());
        _rematch.visible = canRematch;
        _rematch.includeInLayout = canRematch;

        if (_ezObj.isInPlay()) {
            // reset state
            _rematch.selected = false;
            _rematch.enabled = true;
        }
    }

    /**
     * Handle rematch being clicked. We prevent it from being clicked more than once.
     */
    protected function handleRematchClicked (... ignored) :void
    {
        _rematch.enabled = false;
        (_ctrl as WhirledGameController).playerIsReady();
    }

    /**
     * Get the labels for back to lobby, back to whirled, rematch
     */
    protected function getButtonLabels () :Array /* of String */
    {
        throw new Error("abstract");
    }

    /** The player list. */
    protected var _playerList :PlayerList = new PlayerList();

    /** Some buttons. */
    protected var _rematch :CommandButton;
    protected var _backToLobby :CommandButton;
    protected var _backToWhirled :CommandButton;

    /** Would we want to show the rematch button, if the game was over? */
    protected var _showRematch :Boolean = true;
}
}
