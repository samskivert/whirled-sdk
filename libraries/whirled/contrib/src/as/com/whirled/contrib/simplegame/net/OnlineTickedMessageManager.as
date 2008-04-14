package com.whirled.contrib.simplegame.net {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.game.GameControl;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.StateChangedEvent;

import flash.utils.getTimer;

/**
 * A simple manager for sending and receiving messages on an established timeslice boundary.
 * Received messages are grouped by "ticks", which represent timeslices, and are synchronized
 * across clients by a game server.
 */
public class OnlineTickedMessageManager
    implements TickedMessageManager
{
    public function OnlineTickedMessageManager (gameCtrl :GameControl, isFirstPlayer :Boolean, tickIntervalMS :int)
    {
        _gameCtrl = gameCtrl;
        _isFirstPlayer = isFirstPlayer;
        _tickIntervalMS = tickIntervalMS;
    }

    public function addMessageFactory (messageName :String, factory :MessageFactory) :void
    {
        _messageFactories.put(messageName, factory);
    }

    public function setup () :void
    {
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, msgReceived);

        // the game will start when all players are ready
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);

        // we're ready!
        _gameCtrl.game.playerReady();
    }

    public function shutdown () :void
    {
        _gameCtrl.game.removeEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);

        _gameCtrl.services.stopTicker("tick");
        _gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, msgReceived);
        _receivedRandomSeed = false;
    }

    public function get isReady () :Boolean
    {
        return _receivedRandomSeed;
    }

    public function get randomSeed () :uint
    {
        Assert.isTrue(_receivedRandomSeed);
        return _randomSeed;
    }

    protected function handleGameStarted (...ignored) :void
    {
        // When the game starts, send the random seed to everyone.
        // When that is received, start the ticker

        if (_isFirstPlayer) {
            _gameCtrl.net.sendMessage("randSeed", uint(Math.random() * uint.MAX_VALUE));
        }
    }

    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;

        if (name == "randSeed") {
            if (_receivedRandomSeed) {
                log.warning("Error: TickedMessageManager received multiple randSeed messages.");
                return;
            }

            _randomSeed = uint(event.value);
            _receivedRandomSeed = true;

            if (_isFirstPlayer) {
                _gameCtrl.services.startTicker("tick", _tickIntervalMS);
            }

        } else {

            if (!_receivedRandomSeed) {
                log.warning("Error: TickedMessageManager is receiving game messages prematurely.");
                return;
            }

            if (name == "tick") {
                _ticks.push(new Array());
            } else {
                // add any actions received during this tick
                var array :Array = (_ticks[_ticks.length - 1] as Array);
                var msg :Message = deserializeMessage(event.name, event.value);

                if (null != msg) {
                    array.push(msg);
                }
            }
       }
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function sendMessage (msg :Message) :void
    {
        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || (!canSendMessageNow()));

        if (addToQueue) {
            _pendingSends.push(msg);
        } else {
            sendMessageNow(msg);
        }
    }

    protected function canSendMessageNow () :Boolean
    {
        return ((getTimer() - _lastSendTime) >= _minSendDelayMS);
    }

    protected function serializeMessage (msg :Message) :Object
    {
        var factory :MessageFactory = (_messageFactories.get(msg.name) as MessageFactory);
        if (null == factory) {
            log.warning("Discarding outgoing '" + msg.name + "' message (no factory)");
            return null;
        }

        var serialized :Object = factory.serializeForNetwork(msg);

        if (null == serialized) {
            log.warning("Discarding outgoing '" + msg.name + "' message (failed to serialize)");
            return null;
        }

        return serialized;
    }

    protected function deserializeMessage (name :String, serialized :Object) :Message
    {
        var factory :MessageFactory = (_messageFactories.get(name) as MessageFactory);
        if (null == factory) {
            log.warning("Discarding incoming '" + name + "' message (no factory)");
            return null;
        }

        var msg :Message = factory.deserializeFromNetwork(serialized);

        if (null == msg) {
            log.warning("Discarding incoming '" + name + "' message (failed to deserialize)");
            return null;
        }

        return msg;
    }

    protected function sendMessageNow (msg :Message) :void
    {
        var serialized :Object = serializeMessage(msg);
        if (null == serialized) {
            return;
        }

        _gameCtrl.net.sendMessage(msg.name, serialized);
        _lastSendTime = getTimer();
    }

    public function update(dt :Number) :void
    {
        // if there are messages waiting to go out, send one
        if (_pendingSends.length > 0 && canSendMessageNow()) {
            var message :Message = (_pendingSends.shift() as Message);
            sendMessageNow(message);
        }
    }

    public function canSendMessage () :Boolean
    {
        // messages are stored in _pendingSends as two objects - name and data
        return (_pendingSends.length < (_maxPendingSends * 2));
    }

    public function set maxPendingSends (val :uint) :void
    {
        _maxPendingSends = val;
    }

    public function set maxSendsPerSecond (val :uint) :void
    {
        _minSendDelayMS = (0 == val ? 0 : (1000 / val) + 5);
    }

    protected var _isFirstPlayer :Boolean;
    protected var _tickIntervalMS :uint;

    protected var _gameCtrl :GameControl;
    protected var _ticks :Array = [];
    protected var _pendingSends :Array = [];
    protected var _maxPendingSends :uint = 10;
    protected var _minSendDelayMS :uint = 105;  // default to 10 sends/second
    protected var _lastSendTime :int;
    protected var _messageFactories :HashMap = new HashMap();

    protected var _receivedRandomSeed :Boolean;
    protected var _randomSeed :uint;

    protected static const log :Log = Log.getLog(OnlineTickedMessageManager);
}

}