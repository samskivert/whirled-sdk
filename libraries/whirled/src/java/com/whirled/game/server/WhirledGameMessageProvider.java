//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Defines the server-side of the {@link WhirledGameMessageService}.
 */
public interface WhirledGameMessageProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameMessageService#sendMessage} request.
     */
    void sendMessage (ClientObject caller, String arg1, Object arg2, int arg3, int arg4, InvocationService.InvocationListener arg5)
        throws InvocationException;
}