package com.akasha.takion

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
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
                "enableShortcuts" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
                        val manager = getSystemService(ShortcutManager::class.java)

                        val newReleases = ShortcutInfo.Builder(this, "new_releases")
                            .setShortLabel(getString(R.string.shortcut_new_releases_short))
                            .setLongLabel(getString(R.string.shortcut_new_releases_long))
                            .setIcon(Icon.createWithResource(this, R.drawable.ic_shortcut_new_releases))
                            .setIntent(Intent(Intent.ACTION_VIEW, Uri.parse("takion://shortcut/new-releases")))
                            .build()

                        val myPulls = ShortcutInfo.Builder(this, "my_pulls")
                            .setShortLabel(getString(R.string.shortcut_my_pulls_short))
                            .setLongLabel(getString(R.string.shortcut_my_pulls_long))
                            .setIcon(Icon.createWithResource(this, R.drawable.ic_shortcut_inventory))
                            .setIntent(Intent(Intent.ACTION_VIEW, Uri.parse("takion://shortcut/my-pulls")))
                            .build()

                        val library = ShortcutInfo.Builder(this, "library")
                            .setShortLabel(getString(R.string.shortcut_library_short))
                            .setLongLabel(getString(R.string.shortcut_library_long))
                            .setIcon(Icon.createWithResource(this, R.drawable.ic_shortcut_collections_bookmark))
                            .setIntent(Intent(Intent.ACTION_VIEW, Uri.parse("takion://shortcut/library")))
                            .build()

                        manager.setDynamicShortcuts(listOf(newReleases, myPulls, library))
                    }
                    result.success(true)
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
