package `in`.aryasuneesh.daksha

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "daksha/security"

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
    }
}
