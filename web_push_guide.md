# Flutter Web Push Notifications Implementation

## 📝 Firebase Web Configuration

### 1. Add Firebase Config to web/index.html
```html
<!DOCTYPE html>
<html>
<head>
    <!-- Firebase SDKs -->
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js"></script>
</head>
<body>
    <!-- Your Flutter app -->
    <script>
        // Firebase configuration
        const firebaseConfig = {
            apiKey: "your-api-key",
            authDomain: "your-project.firebaseapp.com",
            projectId: "your-project-id",
            storageBucket: "your-project.appspot.com",
            messagingSenderId: "123456789",
            appId: "your-app-id"
        };
        
        // Initialize Firebase
        firebase.initializeApp(firebaseConfig);
    </script>
</body>
</html>
```

### 2. Create Service Worker (web/firebase-messaging-sw.js)
```javascript
// Import Firebase scripts
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js');

// Firebase configuration
const firebaseConfig = {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "your-app-id"
};

// Initialize Firebase in service worker
firebase.initializeApp(firebaseConfig);

// Get messaging instance
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('Background message received:', payload);
    
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/icon-192.png',
        badge: '/icons/badge-72.png',
        tag: 'notification-tag',
        data: payload.data
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    console.log('Notification clicked:', event);
    
    event.notification.close();
    
    // Open or focus the app
    event.waitUntil(
        clients.matchAll({ type: 'window' }).then((clientList) => {
            for (const client of clientList) {
                if (client.url === '/' && 'focus' in client) {
                    return client.focus();
                }
            }
            if (clients.openWindow) {
                return clients.openWindow('/');
            }
        })
    );
});
```

## 🎯 Flutter Web Push Implementation

### 1. Add Web-Specific Firebase Messaging Code

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebPushNotifications {
  static FirebaseMessaging? _messaging;
  
  static Future<void> initialize() async {
    if (kIsWeb) {
      _messaging = FirebaseMessaging.instance;
      
      // Request permission (required for web)
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('Web notification permission: ${settings.authorizationStatus}');
      
      // Get token with VAPID key
      String? token = await _messaging!.getToken(
        vapidKey: "YOUR_VAPID_KEY_FROM_FIREBASE_CONSOLE"
      );
      
      print('Web FCM Token: $token');
      
      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Web foreground message: ${message.notification?.title}');
        
        // Show browser notification
        _showWebNotification(message);
      });
      
      // Handle notification click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Web notification clicked: ${message.notification?.title}');
      });
    }
  }
  
  static void _showWebNotification(RemoteMessage message) {
    // This will trigger the service worker to show notification
    // or you can use web Notification API directly
  }
  
  static Future<String?> getWebToken() async {
    if (kIsWeb && _messaging != null) {
      return await _messaging!.getToken(
        vapidKey: "YOUR_VAPID_KEY_FROM_FIREBASE_CONSOLE"
      );
    }
    return null;
  }
}
```

### 2. Update Main App for Web Support

```dart
// In your main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    // Web-specific Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your-api-key",
        authDomain: "your-project.firebaseapp.com",
        projectId: "your-project-id",
        storageBucket: "your-project.appspot.com",
        messagingSenderId: "123456789",
        appId: "your-app-id"
      )
    );
    
    // Initialize web push notifications
    await WebPushNotifications.initialize();
  } else {
    // Mobile Firebase initialization
    await Firebase.initializeApp();
  }
  
  runApp(const NotificationTestApp());
}
```

### 3. Web-Specific UI Components

```dart
class WebNotificationWidget extends StatefulWidget {
  @override
  _WebNotificationWidgetState createState() => _WebNotificationWidgetState();
}

class _WebNotificationWidgetState extends State<WebNotificationWidget> {
  String _webToken = 'Loading...';
  String _permissionStatus = 'Unknown';
  
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebNotifications();
    }
  }
  
  Future<void> _initWebNotifications() async {
    // Get web token
    String? token = await WebPushNotifications.getWebToken();
    setState(() {
      _webToken = token ?? 'Unable to get web token';
    });
    
    // Check permission status
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    setState(() {
      _permissionStatus = settings.authorizationStatus.toString();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Web FCM Token:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SelectableText(_webToken, style: TextStyle(fontFamily: 'monospace')),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _copyToClipboard(_webToken),
                  child: Text('Copy Token'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permission Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(_permissionStatus),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: Text('Request Permission'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _copyToClipboard(String text) {
    // Web clipboard implementation
    html.window.navigator.clipboard?.writeText(text);
  }
  
  Future<void> _requestPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    setState(() {
      _permissionStatus = settings.authorizationStatus.toString();
    });
  }
}
```

## 🔑 VAPID Key Setup

### Get VAPID Key from Firebase:
1. Firebase Console → Project Settings → Cloud Messaging
2. Web configuration → Generate key pair
3. Copy the "Key pair" value - this is your VAPID key

## 🌐 Web Push Testing

### Send Web Push Notification:
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "WEB_FCM_TOKEN",
    "notification": {
      "title": "Web Push Test",
      "body": "Hello from web push!",
      "icon": "/icons/icon-192.png"
    },
    "webpush": {
      "fcm_options": {
        "link": "https://your-website.com"
      }
    }
  }'
```

## 🚀 Deployment Considerations

### 1. HTTPS Required
- Web push notifications only work over HTTPS
- Use `flutter run -d chrome --web-hostname=localhost --web-port=8080` for local testing

### 2. Browser Support
- ✅ Chrome, Firefox, Safari 16+, Edge
- ❌ Safari < 16, IE

### 3. Permissions
- Users must explicitly grant notification permission
- Permission is domain-specific
- Can be revoked by user anytime

## 🔍 Debugging Web Push

### Browser Console:
```javascript
// Check if notifications are supported
console.log('Notifications supported:', 'Notification' in window);

// Check permission status
console.log('Permission:', Notification.permission);

// Test notification
new Notification('Test', { body: 'Browser notification test' });
```

### Flutter Web Debugging:
```dart
// Add debug prints
print('Web platform: ${kIsWeb}');
print('FCM supported: ${await FirebaseMessaging.instance.isSupported()}');
```

## 📱 Key Differences: Mobile vs Web

| Feature | Mobile | Web |
|---------|--------|-----|
| **Service Worker** | Not needed | Required |
| **VAPID Key** | Not needed | Required |
| **Permission** | App-level | Domain-level |
| **Background** | Native handling | Service Worker |
| **Icon/Sound** | System default | Custom via SW |
| **HTTPS** | Not required | Required |

## 🎯 Complete Web Push Flow

1. **User visits website** → Service worker registers
2. **App requests permission** → Browser shows permission dialog
3. **User grants permission** → FCM generates web token
4. **Backend sends notification** → FCM delivers to service worker
5. **Service worker shows notification** → User sees browser notification
6. **User clicks notification** → App opens/focuses