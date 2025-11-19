import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'dart:io';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("Handling background message: ${message.messageId}");
  } catch (e) {
    debugPrint("Background handler error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const NotificationTestApp());
}

class NotificationTestApp extends StatelessWidget {
  const NotificationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NotificationHomePage(),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage({super.key});

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  static const platform = MethodChannel("azure_nh_channel");
  String _fcmToken = 'Loading...';
  String _azureId = 'Loading...';
  String _deviceId = 'Loading...';
  String _deviceInfo = 'Loading...';
  String _appInfo = 'Loading...';
  final List<String> _notifications = [];
  bool _notificationPermission = false;
  bool _firebaseInitialized = false;
  bool _azureInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check Google Play Services availability first
    if (Platform.isAndroid) {
      await _checkGooglePlayServices();
    }
    
    try {
      await Firebase.initializeApp();
      _firebaseInitialized = true;
    } catch (e) {
      debugPrint('Firebase not configured: $e');
      setState(() {
        _fcmToken = 'Firebase not configured. Add google-services.json (Android) or GoogleService-Info.plist (iOS)';
      });
    }
    
    await _getDeviceInfo();
    await _getAppInfo();
    
    if (_firebaseInitialized) {
      await _requestNotificationPermission();
      await _getFCMToken();
      _setupFirebaseMessaging();
      _listenToAzureNativeNotifications(); 
    }
  }

  Future<void> _checkGooglePlayServices() async {
    try {
      final availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
      debugPrint('🔍 Google Play Services status: $availability');
      
      if (availability != GooglePlayServicesAvailability.success) {
        setState(() {
          _fcmToken = 'Google Play Services issue: $availability\n'
              'Please update Google Play Services on your device.';
        });
        
        // Try to resolve the issue
        if (availability == GooglePlayServicesAvailability.serviceVersionUpdateRequired ||
            availability == GooglePlayServicesAvailability.serviceUpdating) {
          try {
            await GoogleApiAvailability.instance.makeGooglePlayServicesAvailable();
            debugPrint('🔧 Resolution attempt completed');
          } catch (e) {
            debugPrint('🔧 Resolution attempt failed: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Google Play Services check error: $e');
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!_firebaseInitialized) return;
    
    final notificationPermission = await Permission.notification.request();
    setState(() {
      _notificationPermission = notificationPermission.isGranted;
    });

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceData = '';
    String deviceIdentifier = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceData = 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})\n'
          'Device: ${androidInfo.manufacturer} ${androidInfo.model}\n'
          'Brand: ${androidInfo.brand}';
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceData = 'iOS ${iosInfo.systemVersion}\n'
          'Device: ${iosInfo.name} (${iosInfo.model})\n'
          'ID: ${iosInfo.identifierForVendor}';
      deviceIdentifier = iosInfo.identifierForVendor ?? 'Unknown';
    }

    setState(() {
      _deviceInfo = deviceData;
      _deviceId = deviceIdentifier;
    });
  }

  Future<void> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appInfo = 'App: ${packageInfo.appName}\n'
          'Package: ${packageInfo.packageName}\n'
          'Version: ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _getFCMToken() async {
    if (!_firebaseInitialized) return;
    
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Check if Google Play Services is available
      debugPrint('🔍 Checking Google Play Services availability...');
      
      // Wait a bit for services to initialize
      await Future.delayed(const Duration(seconds: 2));
      
      final token = await messaging.getToken();
      debugPrint('🔥 FCM Token obtained: ${token?.substring(0, 20)}...');
      setState(() {
        _fcmToken = token ?? 'Unable to get token';
      });

      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔥 FCM Token refreshed: ${newToken.substring(0, 20)}...');
        setState(() {
          _fcmToken = newToken;
        });
      });
    } catch (e) {
      debugPrint('❌ FCM Token error: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains('SERVICE_NOT_AVAILABLE')) {
        errorMsg = 'Google Play Services not available. Check device setup:\n'
            '1. Update Google Play Services\n'
            '2. Enable Google Play Store\n'
            '3. Add Google account\n'
            '4. Check internet connection\n'
            'Error: $e';
      }
      setState(() {
        _fcmToken = errorMsg;
      });
    }
  }
  
  void _setupFirebaseMessaging() {
    if (!_firebaseInitialized) return;
    
    debugPrint('🔥 Setting up Firebase message listeners...');
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📱 FOREGROUND MESSAGE: ${message.notification?.title}');
      setState(() {
        _notifications.insert(0, 
          'FOREGROUND: ${DateTime.now().toString()}\n'
          'Title: ${message.notification?.title ?? 'No title'}\n'
          'Body: ${message.notification?.body ?? 'No body'}\n'
          'Data: ${message.data.toString()}');
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 APP OPENED FROM NOTIFICATION: ${message.notification?.title}');
      setState(() {
        _notifications.insert(0,
          'OPENED APP: ${DateTime.now().toString()}\n'
          'Title: ${message.notification?.title ?? 'No title'}\n'
          'Body: ${message.notification?.body ?? 'No body'}\n'
          'Data: ${message.data.toString()}');
      });
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📱 APP LAUNCHED FROM NOTIFICATION: ${message.notification?.title}');
        setState(() {
          _notifications.insert(0,
            'APP LAUNCH: ${DateTime.now().toString()}\n'
            'Title: ${message.notification?.title ?? 'No title'}\n'
            'Body: ${message.notification?.body ?? 'No body'}\n'
            'Data: ${message.data.toString()}');
        });
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _listenToAzureNativeNotifications() {
    platform.setMethodCallHandler((call) async {
      switch(call.method) {
        case "onNotificationReceived":
          final payload = Map<String, dynamic>.from(call.arguments);
          print("Azure Notification: $payload");
          setState(() {
            _notifications.insert(
              0,
              'AZURE NATIVE: ${DateTime.now()}\n'
              'Data: ${payload.toString()}'
            );
          });
          debugPrint('🔥 Azure Notification received in Flutter: ${payload.toString()}');
          break;
        case "azureInstallationId":
          print("Azure Installation ID: ${call.arguments}");
          setState(() {
            _azureId = call.arguments;
          });
          break;
        default:
          print("Unknown method called from native: ${call.method}");
      }
    });
  }


  Widget _buildInfoCard(String title, String content, {bool copyable = false}) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (copyable)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(content),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeApp,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _notificationPermission ? Colors.green[100] : Colors.red[100],
              child: Text(
                'Notification Permission: ${_notificationPermission ? "GRANTED" : "DENIED"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _notificationPermission ? Colors.green[800] : Colors.red[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildInfoCard('FCM Token', _fcmToken, copyable: true),
            _buildInfoCard('Azure Installation ID', _azureId, copyable: true),
            _buildInfoCard('Device ID', _deviceId, copyable: true),
            _buildInfoCard('Device Information', _deviceInfo),
            _buildInfoCard('App Information', _appInfo),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Received Notifications (${_notifications.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_notifications.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _notifications.clear();
                              });
                            },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_notifications.isEmpty)
                      const Text('No notifications received yet.')
                    else
                      ...(_notifications.map((notification) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SelectableText(
                          notification,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}