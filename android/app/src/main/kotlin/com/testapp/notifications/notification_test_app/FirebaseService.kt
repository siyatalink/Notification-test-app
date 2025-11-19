package com.testapp.notifications.notification_test_app

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationHub
import android.util.Log

class FirebaseService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)

        Log.d("AzureNH", "FCM token refreshed: $token")

        // Re-register device with Azure Notification Hub
        NotificationHub.start(
            application,
            "Notify",   // Hub name
            "Endpoint=sb://grid-smart-test.servicebus.windows.net/;SharedAccessKeyName=Test-key;SharedAccessKey=PX7OdO7bGLTSsnknjjrGgil2cGBwt4c4dRhjO//ZtQM="
        )

        Log.d("AzureNH", "Azure NH re-registration triggered")
    }
}
