//
// $Id$

package com.whirled.game {

import com.whirled.AbstractSubControl;

/**
 * Provides access to 'services' game services. Do not instantiate this class yourself,
 * access it via GameControl.services.
 */
public class ServicesSubControl extends AbstractSubControl
{
    /**
     * @private Constructed via GameControl.
     */
    public function ServicesSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * Access the 'bags' subcontrol.
     */
    public function get bags () :BagsSubControl
    {
        return _bagsCtrl;
    }

    /**
     * Requests a set of random letters from the dictionary service.  The letters will arrive in a
     * separate message with the specified key, as an array of strings.
     *
     * @param locale RFC 3066 string that represents language settings
     * @param dictionary the dictionary to use, or null for the default.
     *                   TODO: document possible parameters.
     * @param count the number of letters to be produced
     * @param callback the function that will process the results, of the form:
     * <pre>function (letters :Array) :void</pre>
     * where letters is an array of strings containing letters for the given language settings
     * (potentially empty).
     */
    public function getDictionaryLetterSet (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        callHostCode("getDictionaryLetterSet_v2", locale, dictionary, count, callback);
    }

    /**
     * Checks to see if the dictionary for the given locale contains the given word.
     *
     * @param locale RFC 3066 string that represents language settings
     * @param dictionary the dictionary to use, or null for the default.
     *                   TODO: document possible parameters.
     * @param word the string contains the word to be checked
     * @param callback the function that will process the results, of the form:
     * <pre>function (word :String, result :Boolean) :void</pre>
     * where word is a copy of the word that was requested, and result specifies whether the word
     * is valid given language settings
     */
    public function checkDictionaryWord (
        locale :String, dictionary :String, word :String, callback :Function) :void
    {
        callHostCode("checkDictionaryWord_v2", locale, dictionary, word, callback);
    }

    /**
     * Start the ticker with the specified name. The ticker will deliver messages
     * (resulting in a MessageReceivedEvent being dispatched on the 'net' control)
     * to all connected clients, at the specified delay. The value of each message is
     * a single integer, starting with 0 and increasing by 1 with each messsage.
     */
    public function startTicker (tickerName :String, msOfDelay :int) :void
    {
        callHostCode("setTicker_v1", tickerName, msOfDelay);
    }

    /**
     * Stop the specified ticker.
     */
    public function stopTicker (tickerName :String) :void
    {
        startTicker(tickerName, 0);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _bagsCtrl = new BagsSubControl(_parent)
        ];
    }

    /** The bags sub-control. @private */
    protected var _bagsCtrl :BagsSubControl;
}
}