package com.testapp.notifications.notification_test_app

import android.content.Context
import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationListener

class AzureNotificationListener : NotificationListener {

    override fun onPushNotificationReceived(context: Context, message: RemoteMessage) {

        val payload = mapOf(
            "title" to (message.notification?.title ?: ""),
            "body" to (message.notification?.body ?: ""),
            "data" to message.data.toString()
        )

        Log.d("AzureNH", "Forwarding to Flutter: $payload")

        MainActivity.methodChannel?.invokeMethod("onNotificationReceived", payload)
    }
}
