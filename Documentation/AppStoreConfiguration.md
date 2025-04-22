# App Store Connect Configuration for In-App Purchases

This guide provides step-by-step instructions for setting up your in-app purchases in App Store Connect and integrating them with RevenueCat.

## Prerequisites

1. An Apple Developer account ($99/year)
2. Your app already added to App Store Connect
3. A RevenueCat account (offers a free tier to start)

## Step 1: Create an In-App Purchase in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Click on "Features" tab
4. Select "In-App Purchases" from the sidebar
5. Click the "+" button to create a new in-app purchase
6. Select "Auto-Renewable Subscription" as the type
7. Configure your subscription:
   - Reference Name: "Swipely Pro Weekly" (internal name)
   - Product ID: "com.yourdomain.swipely.pro.weekly" (make sure to use your app's bundle ID as the prefix)
   - Subscription Group: Create a new group if this is your first subscription
   - Select the subscription duration (1 week)
   - Set the price
   - Fill out the display name, description, and other details that will be shown to users
   - Upload any promotional images if needed
8. Save the in-app purchase

## Step 2: Create a Subscription Group

If you didn't already have a subscription group:

1. In your in-app purchase configuration, you'll need to create a subscription group
2. Give it a clear name like "Swipely Pro Subscriptions"
3. Configure subscription levels if you'll offer multiple tiers

## Step 3: Configure RevenueCat

1. Log in to your [RevenueCat dashboard](https://app.revenuecat.com/)
2. Add your app if you haven't already
3. In your app settings, make sure you've added your App Store Connect app
4. Configure your Apple App Store credentials for server-to-server verification
5. Go to the "Products" section and add the product ID you created in App Store Connect
6. Create an "Entitlement" (e.g., "pro_features") that will be used to grant access to premium features
7. Link your product to this entitlement
8. Create an "Offering" (e.g., "standard") that contains your subscription package

## Step 4: StoreKit Configuration for Testing

For testing in-app purchases without making real purchases:

1. In Xcode, create a StoreKit configuration file:
   - File > New > File > StoreKit Configuration File
   - Name it "Configuration.storekit"
   - Add your subscription with the same product ID you configured in App Store Connect

2. Enable StoreKit testing in your scheme:
   - Edit your scheme (Product > Scheme > Edit Scheme)
   - Select "Run" on the left
   - Go to the "Options" tab
   - Set "StoreKit Configuration" to your Configuration.storekit file

## Step 5: Update Your RevenueCat API Key in the App

1. In the RevenueCat dashboard, get your API key from your app's settings
2. In your SwipelyApp.swift file, replace "your_api_key_here" with your actual API key:

```swift
// Uncomment and update with your API key
Purchases.configure(withAPIKey: "your_actual_api_key_here")
```

## Step 6: Testing In-App Purchases

1. Run your app in the simulator or on a device
2. Use the testing tools to simulate purchases:
   - In the simulator, purchases will automatically succeed without actual payment
   - For TestFlight, you'll need to set up sandbox testing accounts

3. Test both successful purchase flows and restoration flows

## Step 7: Submission Checklist

Before submitting to the App Store:

1. Ensure your app correctly handles the following scenarios:
   - Successful purchase
   - Failed purchase
   - Restored purchase
   - Subscription expiration
   - Network errors during purchase

2. Add a "Restore Purchases" button that's easily accessible

3. Include appropriate privacy disclosures if you're using device IDs for tracking

4. Make sure your app includes a clear explanation of:
   - What features the subscription unlocks
   - The subscription price and renewal terms
   - How to cancel the subscription

5. Create proper store screenshots showing your in-app purchase flow

## Additional Resources

- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [Apple's In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [App Store Review Guidelines for In-App Purchases](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase) 