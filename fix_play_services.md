# Fix Google Play Services SERVICE_NOT_AVAILABLE

## 🔍 What Causes This Error?
- Google Play Services not installed/updated
- Google Play Store disabled  
- No Google account signed in
- Network connectivity issues
- Device compatibility issues

## 🛠️ Step-by-Step Fixes

### Step 1: Check Google Play Services
On your Android device:
1. **Settings** → **Apps** → **Google Play Services**
2. Check if it's **enabled** and **updated**
3. If disabled → **Enable** it
4. If outdated → **Update** it

### Step 2: Update Google Play Store
1. Open **Google Play Store**
2. If it doesn't open → Enable it in Settings → Apps
3. Go to **My apps & games** → **Update all**

### Step 3: Add Google Account
1. **Settings** → **Accounts** → **Add account** → **Google**
2. Sign in with any Google account
3. Enable sync for the account

### Step 4: Check Network
1. Ensure device has **internet connection**
2. Try both WiFi and mobile data
3. Test by opening Play Store or Chrome

### Step 5: Clear App Data (Last Resort)
1. **Settings** → **Apps** → **Google Play Services**
2. **Storage** → **Clear Data**
3. Restart device
4. Reinstall your notification test app

## 🎯 Test Commands

After fixing, test with:

```bash
# Rebuild and install
flutter clean
flutter build apk --release
flutter install -d YOUR_DEVICE_ID

# Check logs
flutter logs -d YOUR_DEVICE_ID
# Look for: "🔍 Google Play Services status: success"
```

## 🚨 Alternative Solutions

### If Your Device Doesn't Support Google Play:
Some devices (Chinese brands, custom ROMs) don't have Google Play Services.

**Solutions:**
1. Install **microG** (Google Play Services replacement)
2. Use a different test device with official Google Play
3. Test with Firebase Admin SDK directly (server-side)

### For Development/Testing:
You can also test notifications using:
- **Firebase Admin SDK** on server
- **Postman/curl** with FCM REST API
- **Firebase Console** (web interface)

## 📱 Device Compatibility Check

Your device needs:
- ✅ **Android 5.0+** (API 21+)
- ✅ **Google Play Store** installed
- ✅ **Google Play Services** 12.0.0+
- ✅ **Internet connection**
- ✅ **Google account** signed in

## Expected Success Logs:
```
🔍 Google Play Services status: GooglePlayServicesAvailability.success
🔥 FCM Token obtained: [token starts with...]
🔥 Setting up Firebase message listeners...
```