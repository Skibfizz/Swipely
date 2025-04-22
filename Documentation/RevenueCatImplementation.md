# Implementing RevenueCat in Swipely Without Traditional Authentication

## Overview

This document outlines how to implement RevenueCat in the Swipely app to enable premium subscriptions without requiring a traditional user authentication system. The approach will use device identifiers to track users and their subscription status.

## RevenueCat Basics

RevenueCat is a subscription management platform that handles in-app purchases and subscriptions across iOS, Android, and other platforms. It provides a reliable backend and SDK to manage the complex lifecycle of subscriptions without building extensive infrastructure.

Key benefits:
- Handles subscription management and receipt validation
- Provides analytics and insights
- Works across platforms
- Doesn't require a custom database for subscription data

## Implementation Plan for Swipely

### 1. Installation

Add RevenueCat's Purchases SDK to your project using Swift Package Manager:

```swift
// In Xcode:
// File > Add Packages > Search for: https://github.com/RevenueCat/purchases-ios
```

Alternatively, add it to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0")
]
```

### 2. Configuration

In your SwipelyApp.swift file, initialize RevenueCat with your API key:

```swift
import SwiftUI
import Purchases

@main
struct SwipelyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        // RevenueCat configuration
        Purchases.configure(withAPIKey: "your_api_key_here")
        
        // Existing code...
        if let infoDictionary = Bundle.main.infoDictionary {
            // Check if the key doesn't already exist
            if infoDictionary["NSPhotoLibraryUsageDescription"] == nil {
                // This is a workaround, actual Info.plist keys should be set in project settings
                print("Note: Photo Library permission descriptions should be added to Info.plist")
            }
        }
    }
    
    // Rest of the app...
}
```

### 3. User Identification Without Authentication

RevenueCat can work with anonymous users. The SDK will automatically generate a random UUID for each device and use it for tracking purposes. This approach allows you to:

1. Track subscriptions per device
2. Not require user login
3. Still have analytics and revenue tracking

```swift
// RevenueCat automatically creates an app user ID if none is provided
// You can access it with:
let currentAppUserID = Purchases.shared.appUserID
```

If you want to explicitly use a device identifier:

```swift
// Generate a stable device identifier (preferred over UDID which is deprecated)
import UIKit

func getDeviceIdentifier() -> String {
    // Use identifierForVendor which is unique per app per device
    if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
        return deviceID
    }
    
    // Fallback to generating a UUID and storing it
    if let storedID = UserDefaults.standard.string(forKey: "device_identifier") {
        return storedID
    } else {
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: "device_identifier")
        return newID
    }
}

// Then use this ID with RevenueCat
Purchases.configure(withAPIKey: "your_api_key", appUserID: getDeviceIdentifier())
```

### 4. Implementing Free Usage Limits

To track how many photos a user has deleted before requiring a subscription:

```swift
class UsageTracker {
    private static let deletedPhotosCountKey = "deleted_photos_count"
    private static let freeUsageLimit = 10 // Number of free deletions allowed
    
    static var deletedPhotosCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: deletedPhotosCountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deletedPhotosCountKey)
        }
    }
    
    static func incrementDeletedCount() {
        deletedPhotosCount += 1
    }
    
    static func shouldShowPaywall() -> Bool {
        return deletedPhotosCount >= freeUsageLimit
    }
    
    static func resetCount() {
        deletedPhotosCount = 0
    }
}
```

### 5. Paywall and Subscription Logic

When a user exceeds their free limit, show a paywall:

```swift
func handlePhotoDelete() {
    // Increment the count first
    UsageTracker.incrementDeletedCount()
    
    // Check if user reached the limit
    if UsageTracker.shouldShowPaywall() {
        // Show paywall
        showPaywall()
    } else {
        // Continue with normal deletion
        deletePhoto()
    }
}

func showPaywall() {
    // Show subscription options
    Purchases.shared.getOfferings { (offerings, error) in
        if let offerings = offerings {
            // Present your paywall with the available offerings
            let offering = offerings.current
            // Display subscription options to the user
        }
    }
}
```

### 6. Handling Purchases

When a user chooses to subscribe:

```swift
func purchasePackage(_ package: Package) {
    Purchases.shared.purchase(package: package) { (transaction, purchaserInfo, error, userCancelled) in
        if let purchaserInfo = purchaserInfo {
            // Check if user is subscribed
            let subscriptionActive = purchaserInfo.entitlements["pro_features"]?.isActive == true
            
            if subscriptionActive {
                // Enable pro features
                unlockProFeatures()
            }
        }
    }
}
```

### 7. Checking Subscription Status

Before performing premium actions, check if the user is subscribed:

```swift
func checkSubscriptionStatus(completion: @escaping (Bool) -> Void) {
    Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
        let subscriptionActive = purchaserInfo?.entitlements["pro_features"]?.isActive == true
        completion(subscriptionActive)
    }
}

// Usage example
func deletePhoto() {
    checkSubscriptionStatus { isSubscribed in
        if UsageTracker.shouldShowPaywall() && !isSubscribed {
            showPaywall()
        } else {
            // User is subscribed or under free limit, proceed with deletion
            performPhotoDelete()
        }
    }
}
```

### 8. Restoring Purchases

Allow users to restore purchases if they reinstall the app or get a new device:

```swift
func restorePurchases() {
    Purchases.shared.restorePurchases { (purchaserInfo, error) in
        if let purchaserInfo = purchaserInfo {
            let subscriptionActive = purchaserInfo.entitlements["pro_features"]?.isActive == true
            
            if subscriptionActive {
                // Enable pro features
                unlockProFeatures()
            } else {
                // No active subscription found
            }
        }
    }
}
```

## RevenueCat Dashboard Setup

1. Create an account at [RevenueCat](https://www.revenuecat.com/)
2. Create a new app in the dashboard
3. Configure your app's API keys (iOS)
4. Set up products in App Store Connect
5. Configure the same products in the RevenueCat dashboard
6. Create an entitlement (e.g., "pro_features")
7. Link your products to the entitlement
8. Create an offering with your packages (e.g., weekly subscription)

## Limitations of Device ID Approach

- Users can't transfer subscriptions between devices easily
- If users reset their device or clear app data, they need to restore purchases
- No cross-platform subscription synchronization without user accounts

## Next Steps

1. Sign up for RevenueCat and create your app
2. Configure products in App Store Connect and RevenueCat
3. Implement the SDK in your app
4. Create usage tracking logic
5. Implement the paywall UI
6. Test purchases with sandbox accounts
