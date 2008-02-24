//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.utils.ByteArray;
import com.threerings.io.TypedArray;
import com.threerings.util.Integer;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ResultMarshaller;
import com.whirled.game.client.WhirledGameService;

/**
 * An ActionScript version of the Java WhirledGameService interface.
 */
public interface WhirledGameService extends InvocationService
{
    // from Java interface WhirledGameService
    function addToCollection (arg1 :Client, arg2 :String, arg3 :TypedArray /* of class [B */, arg4 :Boolean, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function awardPrize (arg1 :Client, arg2 :String, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function awardTrophy (arg1 :Client, arg2 :String, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function checkDictionaryWord (arg1 :Client, arg2 :String, arg3 :String, arg4 :String, arg5 :InvocationService_ResultListener) :void;

    // from Java interface WhirledGameService
    function endGame (arg1 :Client, arg2 :TypedArray /* of int */, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endGameWithScores (arg1 :Client, arg2 :TypedArray /* of int */, arg3 :TypedArray /* of int */, arg4 :int, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endGameWithWinners (arg1 :Client, arg2 :TypedArray /* of int */, arg3 :TypedArray /* of int */, arg4 :int, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endRound (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endTurn (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function getCookie (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function getDictionaryLetterSet (arg1 :Client, arg2 :String, arg3 :String, arg4 :int, arg5 :InvocationService_ResultListener) :void;

    // from Java interface WhirledGameService
    function getFromCollection (arg1 :Client, arg2 :String, arg3 :Boolean, arg4 :int, arg5 :String, arg6 :int, arg7 :InvocationService_ConfirmListener) :void;

    // from Java interface WhirledGameService
    function mergeCollection (arg1 :Client, arg2 :String, arg3 :String, arg4 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function restartGameIn (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function sendMessage (arg1 :Client, arg2 :String, arg3 :Object, arg4 :int, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function setCookie (arg1 :Client, arg2 :ByteArray, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function setProperty (arg1 :Client, arg2 :String, arg3 :Object, arg4 :Integer, arg5 :Boolean, arg6 :Boolean, arg7 :Object, arg8 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function setTicker (arg1 :Client, arg2 :String, arg3 :int, arg4 :InvocationService_InvocationListener) :void;
}
}