//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Dispatched to pets, when they overhear chatter in the room.
 * 
 * @eventType com.whirled.ControlEvent.RECEIVED_CHAT
 */
[Event(name="receivedChat", type="com.whirled.ControlEvent")]

/**
 * Defines actions, accessors and callbacks available to all Pets.
 */
public class PetControl extends ActorControl
{
    /**
     * Creates a controller for a Pet. The display object is the Pet's visualization.
     */
    public function PetControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Send a chat message to the entire room. The chat message will be treated as if it
     * was typed in at the chat message box - it will be filtered.
     * TODO: Any action commands (e.g. /emote) should be handled appropriately.
     */
    public function sendChat (msg :String) :void
    {
        callHostCode("sendChatMessage_v1", msg);
    }

    /**
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["receivedChat_v2"] = receivedChat_v2;
    }

    /**
     * Called when the pet is overhearing a line of chatter in the room.
     * If this instance of the pet has control, it will dispatch a new receivedChat event,
     * otherwise the line will be ignored.
     * @private
     */
    protected function receivedChat_v2 (entityId :String, message :String) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.RECEIVED_CHAT, entityId, message);
        }
    }
}
}
