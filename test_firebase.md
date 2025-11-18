# Firebase FCM Test Instructions

## ✅ Configuration Status
- ✅ `google-services.json` added to `/android/app/`
- ✅ Firebase plugins configured in `build.gradle.kts`
- ✅ FCM dependencies added to `pubspec.yaml`

## 🧪 Testing Steps

### 1. Restart the App
Since you've added the Firebase configuration, you need to completely restart the app:
```bash
# Stop the current app (Ctrl+C in terminal)
# Then run:
flutter run
```

### 2. Expected Results After Restart
Once restarted, the app should show:
- ✅ **FCM Token**: A long string (instead of "Firebase not configured")
- ✅ **Notification Permission**: Status (GRANTED/DENIED)
- ✅ **Device ID**: Your device identifier
- ✅ **Device Info**: Android version and device details

### 3. Test Push Notifications

#### Option A: Using Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `notify-289ce`
3. Go to **Cloud Messaging** in left sidebar
4. Click **Send your first message**
5. Fill in:
   - **Notification title**: "Test Notification"
   - **Notification text**: "Hello from Firebase!"
6. Click **Next**
7. Select **Target**: Choose your Android app
8. Click **Next**, then **Review**, then **Publish**

#### Option B: Using curl command
Replace `YOUR_FCM_TOKEN` with the token from your app:

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/notify-289ce/messages:send \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test from Backend",
        "body": "This is a test notification!"
      },
      "data": {
        "test_key": "test_value"
      }
    }
  }'
```

### 4. What to Look For

In your Flutter app, you should see notifications logged in the **"Received Notifications"** section when:
- ✅ **App is in foreground**: Shows as "FOREGROUND"
- ✅ **App is in background**: Shows as "OPENED APP" when tapped
- ✅ **App is closed**: Shows as "APP LAUNCH" when opened via notification

### 5. Backend Integration Info

For your backend team, they need:
- **Project ID**: `notify-289ce`
- **FCM Token**: Copy from the app (the long string)
- **Package Name**: `com.testapp.notifications.notification_test_app`

### 6. Troubleshooting

If FCM token still shows "Firebase not configured":
1. Ensure `google-services.json` is in `/android/app/` folder
2. Restart the app completely (not hot reload)
3. Check Android Studio logs for any Firebase init errors
4. Verify the package name in `google-services.json` matches your app

## 📝 Test Results Template

After testing, document:
- [ ] FCM Token displayed successfully
- [ ] Notification permission granted
- [ ] Foreground notifications received
- [ ] Background notifications received
- [ ] Notification data logged correctly
- [ ] Click actions work properly