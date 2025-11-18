#!/bin/bash

# Firebase FCM Test Script
# Replace YOUR_FCM_TOKEN with the token from your Flutter app
# Replace YOUR_SERVER_KEY with your Firebase Server Key

FCM_TOKEN="YOUR_FCM_TOKEN_HERE"
SERVER_KEY="YOUR_SERVER_KEY_HERE"

echo "Testing Firebase FCM notification..."
echo "Make sure to replace YOUR_FCM_TOKEN and YOUR_SERVER_KEY with actual values!"

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "'$FCM_TOKEN'",
    "notification": {
      "title": "Test from Backend",
      "body": "This notification was sent using curl!",
      "sound": "default"
    },
    "data": {
      "test_key": "test_value",
      "timestamp": "'$(date)'"
    }
  }'