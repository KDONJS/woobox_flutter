package com.iqonic.flutter_woobox

import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication

class App : FlutterApplication() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}