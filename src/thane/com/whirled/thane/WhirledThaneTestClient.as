//
// $Id$

package com.whirled.thane {

import avmplus.System;
import com.whirled.bureau.client.WhirledBureauClient;
import com.whirled.thane.HttpUserCodeLoader;

public class WhirledThaneTestClient
{
    WhirledBureauClient.main(
        System.argv, "0", new HttpUserCodeLoader());
}
}