package com.testapp.notifications.notification_test_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.FirebaseApp
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationHub

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "azure_nh_channel"
        var methodChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        FirebaseApp.initializeApp(this)

        NotificationHub.setListener(AzureNotificationListener())

        NotificationHub.start(
            application,
            "Notify",
            "Endpoint=sb://grid-smart-test.servicebus.windows.net/;SharedAccessKeyName=Test-key;SharedAccessKey=<Key//ZtQM=>"
        )

        val installationId = NotificationHub.getInstallationId()
        if (installationId != null) {
            methodChannel?.invokeMethod("azureInstallationId", installationId)
        }
    }
}
