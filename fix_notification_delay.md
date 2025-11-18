# Fix FCM Notification Delays

## 🔧 Immediate Fixes for Emulator

### 1. Disable Doze Mode & Battery Optimization
Run these ADB commands while emulator is running:

```bash
# Disable doze mode
adb shell dumpsys deviceidle disable

# Disable app standby  
adb shell dumpsys deviceidle disable deep

# Keep screen partially awake
adb shell settings put global stay_on_while_plugged_in 3

# Disable battery optimization for your app
adb shell dumpsys deviceidle whitelist +com.testapp.notifications.notification_test_app
```

### 2. Force FCM High Priority
In Firebase Console when sending test message:
- Click "Additional options" 
- Set **Priority**: "High"
- Set **TTL**: 0 (immediate delivery)

### 3. Keep App Active
- Keep your app in foreground (visible on screen)
- Or add a simple keep-alive mechanism

## 🎯 Test on Real Device

**Best Solution**: Test on a real Android device instead of emulator:
1. Enable USB Debugging on your phone
2. Connect via USB
3. Run: `flutter run -d [your-device-id]`

Real devices have much better FCM performance than emulators.

## 📱 Emulator Settings to Change

### 1. Create Better Emulator
- Use **Pixel 6** or newer device template
- **API Level 30+** (you have 36 ✅)
- **Google Play** image (not Google APIs)
- **RAM**: 4GB+ 
- **Enable Hardware Acceleration**

### 2. Network Settings
In emulator:
- Settings → Network → WiFi → Advanced
- Keep WiFi on during sleep: **Always**
- Settings → Battery → Battery optimization → Your app → **Don't optimize**

## 🔥 High Priority Notification Code

Add this for instant delivery from your backend: