⚠️ IMPORTANT: key.properties contains sensitive credentials

This file has been added to .gitignore to prevent it from being committed.

To set up signing on a new machine:
1. Copy your keystore file (upload-keystore.jks) to android/
2. Create android/key.properties with:
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks

DO NOT commit these files to version control!
