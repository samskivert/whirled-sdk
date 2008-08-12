//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Superclass for controls that are instantiated in association with a specific
 * target, e.g. roomId or playerId. It centralizes the targetId member and sends
 * it automatically as the first argument to all backend functions.
 */
public class TargetedSubControl extends AbstractSubControl
{
    public function TargetedSubControl (parent :AbstractControl, targetId :int)
    {
        _targetId = targetId;

        super(parent);
    }

    /** @private */
    override protected function callHostCode (name :String, ... args) :*
    {
        args.unshift(_targetId);
        return super.callHostCode(name, args);
    }

    /** @private */
    protected var _targetId :int = 0;
}
}