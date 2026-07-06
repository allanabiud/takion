package com.akasha.takion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "takion/native_timezone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLocalTimezone" -> {
                    try {
                        val tz = java.util.TimeZone.getDefault().id
                        result.success(tz)
                    } catch (e: Exception) {
                        result.error("TZ_ERROR", "Could not get timezone", e.localizedMessage)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
