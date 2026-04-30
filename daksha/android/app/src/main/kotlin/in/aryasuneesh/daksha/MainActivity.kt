package `in`.aryasuneesh.daksha

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "daksha/security"
    private val WINDOW_CHANNEL = "daksha/window"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "hasInternetPermission") {
                val pm = applicationContext.packageManager
                val hasInternet = pm.checkPermission(
                    android.Manifest.permission.INTERNET,
                    applicationContext.packageName
                ) == PackageManager.PERMISSION_GRANTED
                result.success(hasInternet)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WINDOW_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecure" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disableSecure" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
