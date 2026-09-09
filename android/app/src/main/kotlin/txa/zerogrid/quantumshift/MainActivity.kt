package txa.zerogrid.quantumshift

import android.content.Context
import android.os.Build
import android.os.Bundle
import com.google.android.gms.games.PlayGamesSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.PrintWriter
import java.io.StringWriter

class MainActivity : FlutterActivity() {
    private val CRASH_CHANNEL = "txa.zerogrid.quantumshift/native_crash"
    private var methodChannel: MethodChannel? = null

    companion object {
        private const val PREFS_NAME = "txa_native_crash_prefs"
        private const val KEY_HAS_CRASH = "has_native_crash"
        private const val KEY_ERROR_MSG = "native_error_msg"
        private const val KEY_STACK_TRACE = "native_stack_trace"
        private const val KEY_THREAD_NAME = "native_thread_name"
        private const val KEY_TIMESTAMP = "native_timestamp"
        private const val KEY_DEVICE_INFO = "native_device_info"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        setupNativeCrashHandler()
        try {
            PlayGamesSdk.initialize(this)
        } catch (_: Exception) {}
        super.onCreate(savedInstanceState)
    }

    private fun setupNativeCrashHandler() {
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            saveNativeCrash(thread, throwable)

            // Cố gắng gửi ngay tới Flutter nếu engine còn đang sống
            try {
                runOnUiThread {
                    try {
                        val crashMap = mapOf(
                            "error" to "${throwable.javaClass.name}: ${throwable.message ?: "No error message"}",
                            "stackTrace" to getStackTraceString(throwable),
                            "thread" to thread.name,
                            "timestamp" to System.currentTimeMillis().toString(),
                            "device" to getDeviceInfo()
                        )
                        methodChannel?.invokeMethod("onNativeCrash", crashMap)
                    } catch (_: Exception) {}
                }
            } catch (_: Exception) {}

            defaultHandler?.uncaughtException(thread, throwable)
        }
    }

    private fun saveNativeCrash(thread: Thread, throwable: Throwable) {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val stackTrace = getStackTraceString(throwable)
            val errorMsg = "${throwable.javaClass.name}: ${throwable.message ?: "No error message"}"

            prefs.edit()
                .putBoolean(KEY_HAS_CRASH, true)
                .putString(KEY_ERROR_MSG, errorMsg)
                .putString(KEY_STACK_TRACE, stackTrace)
                .putString(KEY_THREAD_NAME, thread.name)
                .putString(KEY_TIMESTAMP, System.currentTimeMillis().toString())
                .putString(KEY_DEVICE_INFO, getDeviceInfo())
                .commit() // Ghi đồng bộ ngay lập tức trước khi tiến trình Android bị đóng
        } catch (_: Exception) {}
    }

    private fun getStackTraceString(throwable: Throwable): String {
        val sw = StringWriter()
        throwable.printStackTrace(PrintWriter(sw))
        return sw.toString()
    }

    private fun getDeviceInfo(): String {
        return "Android ${Build.VERSION.RELEASE} (SDK ${Build.VERSION.SDK_INT}) - ${Build.MANUFACTURER} ${Build.MODEL}"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CRASH_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingNativeCrash" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val hasCrash = prefs.getBoolean(KEY_HAS_CRASH, false)
                    if (hasCrash) {
                        val crashData = mapOf(
                            "error" to (prefs.getString(KEY_ERROR_MSG, "") ?: ""),
                            "stackTrace" to (prefs.getString(KEY_STACK_TRACE, "") ?: ""),
                            "thread" to (prefs.getString(KEY_THREAD_NAME, "") ?: ""),
                            "timestamp" to (prefs.getString(KEY_TIMESTAMP, "") ?: ""),
                            "device" to (prefs.getString(KEY_DEVICE_INFO, "") ?: "")
                        )
                        // Xóa cờ sau khi bàn giao cho Flutter
                        prefs.edit().clear().commit()
                        result.success(crashData)
                    } else {
                        result.success(null)
                    }
                }
                "clearNativeCrash" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().clear().commit()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Kênh kiểm tra tính khả dụng của Google Play Services (GMS)
        val gmsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "txa.zerogrid.quantumshift/gms")
        gmsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkGms" -> {
                    try {
                        val availability = com.google.android.gms.common.GoogleApiAvailability.getInstance()
                        val status = availability.isGooglePlayServicesAvailable(this)
                        val isSuccess = (status == com.google.android.gms.common.ConnectionResult.SUCCESS)
                        val isUserResolvable = availability.isUserResolvableError(status)
                        result.success(mapOf(
                            "isAvailable" to isSuccess,
                            "statusCode" to status,
                            "isUserResolvable" to isUserResolvable
                        ))
                    } catch (_: Throwable) {
                        result.success(mapOf(
                            "isAvailable" to false,
                            "statusCode" to -1,
                            "isUserResolvable" to false
                        ))
                    }
                }
                "openPlayServicesStore" -> {
                    try {
                        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                            data = android.net.Uri.parse("market://details?id=com.google.android.gms")
                            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            val webIntent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                                data = android.net.Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.gms")
                                addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(webIntent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
