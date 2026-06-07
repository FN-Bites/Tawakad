package com.example.tawakad_app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.FirebaseFirestore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "تذكير"
        val body = intent.getStringExtra("body") ?: ""
        val id = intent.getIntExtra("id", 0)
        val isPost = intent.getBooleanExtra("isPost", false)
        val listId = intent.getStringExtra("listId") ?: ""
        val userId = intent.getStringExtra("userId") ?: ""

        if (isPost && listId.isNotEmpty() && userId.isNotEmpty()) {
            FirebaseApp.initializeApp(context)
            val db = FirebaseFirestore.getInstance()
            db.collection("users").document(userId)
                .collection("lists").document(listId).get()
                .addOnSuccessListener { doc ->
                    if (doc.exists()) {
                        val items = doc.get("items") as? List<*> ?: emptyList<Any>()
                        val checked = doc.get("checkedIndices") as? List<*> ?: emptyList<Any>()

                        if (items.isEmpty()) return@addOnSuccessListener

                        val checkedSet = checked.mapNotNull { entry ->
                            when (entry) {
                                is Long -> entry.toInt()
                                is Int  -> entry
                                else    -> null
                            }
                        }.toSet()

                        val uncheckedItems = items.filterIndexed { index, _ -> index !in checkedSet }

                        when {
                            uncheckedItems.isEmpty() -> {
                                showNotification(
                                    context, id,
                                    "🎉 ${title.removeSuffix(" ⚠️ ")} جاهز!",
                                    "أحسنت! جميع أغراض القائمة جاهزة."
                                )
                            }
                            uncheckedItems.size == 1 -> {
                                showNotification(
                                    context, id, title,
                                    "لم تقم بتجهيز \"${uncheckedItems.first()}\" بعد!"
                                )
                            }
                            uncheckedItems.size == 2 -> {
                                showNotification(
                                    context, id, title,
                                    "لديك غرضان لم يتم تجهيزهما بعد!"
                                )
                            }
                            uncheckedItems.size <= 10 -> {
                                // 3–10: Arabic-Indic count + أغراض
                                val arabicCount = uncheckedItems.size.toString()
                                    .map { ch ->
                                        when (ch) {
                                            '0' -> '٠'; '1' -> '١'; '2' -> '٢'; '3' -> '٣'
                                            '4' -> '٤'; '5' -> '٥'; '6' -> '٦'; '7' -> '٧'
                                            '8' -> '٨'; '9' -> '٩'; else -> ch
                                        }
                                    }.joinToString("")
                                showNotification(
                                    context, id, title,
                                    "لديك $arabicCount أغراض لم يتم تجهيزها بعد!"
                                )
                            }
                            else -> {
                                // 11+: Arabic-Indic count + غرض
                                val arabicCount = uncheckedItems.size.toString()
                                    .map { ch ->
                                        when (ch) {
                                            '0' -> '٠'; '1' -> '١'; '2' -> '٢'; '3' -> '٣'
                                            '4' -> '٤'; '5' -> '٥'; '6' -> '٦'; '7' -> '٧'
                                            '8' -> '٨'; '9' -> '٩'; else -> ch
                                        }
                                    }.joinToString("")
                                showNotification(
                                    context, id, title,
                                    "لديك $arabicCount غرضًا لم يتم تجهيزها بعد!"
                                )
                            }
                        }
                    } else {
                        showNotification(context, id, title, body)
                    }
                }
                .addOnFailureListener {
                    showNotification(context, id, title, body)
                }
        } else {
            showNotification(context, id, title, body)
        }
    }

    private fun showNotification(context: Context, id: Int, title: String, body: String) {
        val channelId = "pack_list_channel"
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "تذكيرات القوائم", NotificationManager.IMPORTANCE_HIGH
            )
            nm.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        nm.notify(id, notification)
    }
}

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "android_channel")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        val id = call.argument<Int>("id") ?: 0
                        val title = call.argument<String>("title") ?: ""
                        val body = call.argument<String>("body") ?: ""
                        val triggerMs = call.argument<Long>("triggerMs") ?: 0L
                        val isPost = call.argument<Boolean>("isPost") ?: false
                        val listId = call.argument<String>("listId") ?: ""
                        val userId = call.argument<String>("userId") ?: ""
                        scheduleAlarm(id, title, body, triggerMs, isPost, listId, userId)
                        result.success(null)
                    }
                    "cancelAlarm" -> {
                        val id = call.argument<Int>("id") ?: 0
                        cancelAlarm(id)
                        result.success(null)
                    }
                    "ignoreBatteryOptimization" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                                val intent = Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName")
                                )
                                startActivity(intent)
                            }
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleAlarm(
        id: Int, title: String, body: String,
        triggerMs: Long, isPost: Boolean, listId: String, userId: String
    ) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("isPost", isPost)
            putExtra("listId", listId)
            putExtra("userId", userId)
        }
        val pi = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerMs, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerMs, pi)
        }
    }

    private fun cancelAlarm(id: Int) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pi)
    }
}