package com.akasha.takion

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "takion/native_timezone"
    private val SHORTCUT_CHANNEL = "takion/shortcut"
    private var pendingShortcut: String? = null

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHORTCUT_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingRoute" -> {
                    result.success(pendingShortcut)
                    pendingShortcut = null
                }
                else -> result.notImplemented()
            }
        }

        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = extractRoute(intent)
        if (route != null) {
            pendingShortcut = route
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                try {
                    MethodChannel(it, SHORTCUT_CHANNEL).invokeMethod("navigate", route)
                } catch (_: Exception) { }
            }
        }
    }

    private fun handleIntent(intent: Intent) {
        val route = extractRoute(intent)
        if (route != null) {
            pendingShortcut = route
        }
    }

    private fun extractRoute(intent: Intent): String? {
        val data = intent.data?.toString() ?: return null
        val prefix = "takion://shortcut/"
        return if (data.startsWith(prefix)) data.removePrefix(prefix) else null
    }
}
