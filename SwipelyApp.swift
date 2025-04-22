//
//  SwipelyApp.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import SuperwallKit
import StoreKit
// Import only what's needed, no RevenueCat references

// Helper class to handle notifications
class OnboardingStateManager {
    static let shared = OnboardingStateManager()
    
    func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RestartOnboarding"),
            object: nil,
            queue: .main) { _ in
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            }
    }
}

@main
struct SwipelyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSelectedPhotoGroup") private var hasSelectedPhotoGroup = false
    @AppStorage("hasSubscribed") private var hasSubscribed = false
    
    // Store the delegate as a property
    private let superwallDelegate = SuperwallDelegateHandler()
    
    init() {
        // Configure Superwall first
        Superwall.configure(apiKey: "pk_c305526b51a785bae025f189ec26332bcb6a0d0bd81b94fd")
        
        // Set the delegate
        Superwall.shared.delegate = superwallDelegate
        
        // Set initial subscription status based on UserDefaults
        if hasSubscribed {
            Superwall.shared.subscriptionStatus = .active([])
        } else {
            Superwall.shared.subscriptionStatus = .inactive
        }
        
        // Identify the user
        let userId = getOrCreateAppUserID()
        Superwall.shared.identify(userId: userId)
        
        // Setup StoreKit transaction observer
        setupStoreKitObserver()
        
        // App initialization
        setupApp()
        
        // Add permission descriptions to Info.plist at runtime
        if let infoDictionary = Bundle.main.infoDictionary {
            // Check if the key doesn't already exist
            if infoDictionary["NSPhotoLibraryUsageDescription"] == nil {
                // This is a workaround, actual Info.plist keys should be set in project settings
                print("Note: Photo Library permission descriptions should be added to Info.plist")
            }
        }
        
        // Reset hasSelectedPhotoGroup to false on app startup to ensure
        // the user can select a photo group even if the app crashed previously
        hasSelectedPhotoGroup = false
        
        // Setup notification observers
        OnboardingStateManager.shared.setupObservers()
        
        // Also listen for subscription status changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SubscriptionStatusChanged"),
            object: nil,
            queue: .main) { notification in
                if let isSubscribed = notification.object as? Bool {
                    UserDefaults.standard.set(isSubscribed, forKey: "hasSubscribed")
                    Superwall.shared.subscriptionStatus = isSubscribed ? .active([]) : .inactive
                }
            }
    }
    
    // Setup StoreKit transaction observer
    private func setupStoreKitObserver() {
        // For StoreKit 1
        #if os(iOS)
        if #available(iOS 15.0, *) {
            // Use StoreKit 2 on iOS 15+
            Task {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        // Handle the transaction
                        if transaction.revocationDate == nil {
                            // Valid transaction, update subscription status
                            UserDefaults.standard.set(true, forKey: "hasSubscribed")
                            Superwall.shared.subscriptionStatus = .active([])
                        } else {
                            // Revoked subscription
                            UserDefaults.standard.set(false, forKey: "hasSubscribed")
                            Superwall.shared.subscriptionStatus = .inactive
                        }
                        // Finish the transaction
                        await transaction.finish()
                    }
                }
            }
        } else {
            // StoreKit 1 fallback for older iOS versions
            SKPaymentQueue.default().add(StoreKitTransactionObserver.shared)
        }
        #endif
    }
    
    // Setup app initialization
    private func setupApp() {
        print("App initialization started")
    }
    
    // Generate a persistent user ID
    private func getOrCreateAppUserID() -> String {
        let userDefaultsKey = "swipely_app_user_id"
        
        if let existingUserID = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return existingUserID
        } else {
            let newUserID = UUID().uuidString
            UserDefaults.standard.set(newUserID, forKey: userDefaultsKey)
            return newUserID
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                ContentView()
            }
        }
    }
}

// Delegate handler for Superwall
class SuperwallDelegateHandler: SuperwallDelegate {
    func didFailToPresent(paywallInfo: SuperwallKit.PaywallInfo, error: Error) {
        print("Failed to present paywall: \(error.localizedDescription)")
        // Handle the error - perhaps show a fallback UI or log analytics
    }
    
    func subscription(status: SuperwallKit.SubscriptionStatus) {
        // Update app state based on subscription status changes
        let isSubscribed = status != .inactive
        NotificationCenter.default.post(
            name: NSNotification.Name("SubscriptionStatusChanged"),
            object: isSubscribed
        )
    }
    
    func willPresentPaywall(withInfo paywallInfo: SuperwallKit.PaywallInfo) {
        print("About to present paywall: \(paywallInfo.identifier)")
    }
    
    func didPresentPaywall(withInfo paywallInfo: SuperwallKit.PaywallInfo) {
        print("Did present paywall: \(paywallInfo.identifier)")
    }
    
    func willDismissPaywall(withInfo paywallInfo: SuperwallKit.PaywallInfo) {
        print("About to dismiss paywall: \(paywallInfo.identifier)")
    }
    
    func didDismissPaywall(withInfo paywallInfo: SuperwallKit.PaywallInfo) {
        print("Did dismiss paywall: \(paywallInfo.identifier)")
    }
}

// Helper for Superwall feature gating
class PaywallManager {
    static let shared = PaywallManager()
    
    // Example placements - define all your feature placements here
    struct Placements {
        static let batchDelete = "batch_delete"
        static let bulkExport = "bulk_export"
        static let customFilters = "custom_filters"
        static let cloudBackup = "cloud_backup"
        // Add more placements as needed
    }
    
    /// Registers a placement with Superwall and executes the action if the user has access
    /// - Parameters:
    ///   - placement: The feature placement identifier
    ///   - action: The closure to execute if the user has access
    func registerFeature(placement: String, action: @escaping () -> Void) {
        // Check if user is a subscriber first (optional optimization)
        if UserDefaults.standard.bool(forKey: "hasSubscribed") {
            // User is already a subscriber, proceed with action
            action()
            return
        }
        
        // Show paywall if needed
        Superwall.shared.register(placement: placement) {
            // This code runs only if user gets access (purchases or already has access)
            action()
        }
    }
    
    /// Example of how to use a paywall with custom parameters
    func registerFeatureWithParams(placement: String, params: [String: Any], action: @escaping () -> Void) {
        Superwall.shared.register(placement: placement, params: params) {
            action()
        }
    }
}

// StoreKit 1 transaction observer
class StoreKitTransactionObserver: NSObject, SKPaymentTransactionObserver {
    static let shared = StoreKitTransactionObserver()
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                // Transaction is successful
                UserDefaults.standard.set(true, forKey: "hasSubscribed")
                Superwall.shared.subscriptionStatus = .active([])
                queue.finishTransaction(transaction)
                
            case .failed:
                // Transaction failed
                print("Payment failed: \(transaction.error?.localizedDescription ?? "Unknown error")")
                queue.finishTransaction(transaction)
                
            case .deferred, .purchasing:
                // Transaction in progress
                break
                
            @unknown default:
                break
            }
        }
    }
}
