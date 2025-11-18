# FCM Notification Troubleshooting Checklist

## ✅ Pre-flight Checks

### 1. Emulator Requirements
- [ ] **Google Play Services**: Emulator must have Google Play (not Google APIs only)
- [ ] **API Level**: 19+ (you have API 36 ✅)
- [ ] **Network**: Emulator has internet connectivity

### 2. App State Tests
Try sending notifications in each state:

#### A. **Foreground Test** (App Open & Visible)
- [ ] App is open and visible on screen
- [ ] Send test from Firebase Console
- [ ] **Expected**: Message appears in "Received Notifications" section immediately
- [ ] **Expected**: Console shows: `📱 FOREGROUND MESSAGE: [title]`

#### B. **Background Test** (App Minimized) 
- [ ] Minimize app (home button, don't kill it)
- [ ] Send test from Firebase Console
- [ ] **Expected**: Android notification appears in notification tray
- [ ] Tap notification to open app
- [ ] **Expected**: Message logged as "OPENED APP"

#### C. **Killed App Test**
- [ ] Force close app completely
- [ ] Send test from Firebase Console  
- [ ] **Expected**: Android notification appears in notification tray
- [ ] Tap to launch app
- [ ] **Expected**: Message logged as "APP LAUNCH"

### 3. Firebase Console Settings
When sending from Firebase Console, ensure:
- [ ] **Target**: "Single device" (not "User segment")
- [ ] **FCM Token**: Copied exactly from your Flutter app
- [ ] **Title & Body**: Both filled in
- [ ] **Send time**: "Now" (not scheduled)

### 4. Debug Console Commands
Run while app is running:

```bash
# Check if app is connected and logs
flutter logs -d emulator-5554

# Look for these log messages:
# 🔥 FCM Token obtained: [token]...
# 🔥 Setting up Firebase message listeners...
# 📱 FOREGROUND MESSAGE: [when notification received]
```

### 5. Alternative Test Method
If Firebase Console doesn't work, try this curl command:

```bash
# Get your Server Key from Firebase Console → Project Settings → Cloud Messaging
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "Hello from curl!"
    }
  }'
```

## 🔍 Common Solutions

### **No Notifications at All:**
1. Restart emulator with Google Play Store image
2. Ensure internet connection works in emulator  
3. Check if Firebase project has FCM enabled
4. Verify package name matches exactly in Firebase

### **Only Foreground Works:**
1. Check Android notification permissions
2. Verify Google Play Services is updated in emulator
3. Test on real device instead of emulator

### **Token Issues:**
1. Clear app data and restart
2. Check if token is being generated (should be ~150+ characters)
3. Regenerate token by reinstalling app

## 📱 Emulator Setup Check

### Create New Google Play Emulator:
1. Android Studio → AVD Manager
2. Create Virtual Device
3. **Important**: Choose system image with "Google Play" (not just "Google APIs")
4. Start emulator
5. Set up Google account in emulator
6. Update Google Play Services

### Quick Test:
- Open Google Play Store in emulator
- If it works → FCM should work
- If it crashes → Create new emulator with Google Play image