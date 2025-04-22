import SwiftUI
// Import only what's needed, no external purchase SDKs

// Mock structures for test mode
struct MockOfferings {
    var current: MockCurrentOffering?
}

struct MockCurrentOffering {
    var monthly: MockPackage
    var annual: MockPackage
}

struct MockPackage {
    var identifier: String
    var packageType: String
    var product: MockProduct
    var offering: String
}

struct MockProduct {
    var identifier: String
    var price: Decimal
    var priceString: String
    var title: String
}

// Type alias for compatibility with existing code
typealias Offerings = MockOfferings
typealias Package = MockPackage

/// Manages pro features and subscription state for Swipely
class ProManager: ObservableObject {
    // MARK: - Properties
    
    /// Published property that indicates whether the user has pro features
    @Published private(set) var isProUser = false
    
    /// Number of free photo deletions allowed before showing paywall
    private let freePhotoDeletionLimit = 10
    
    /// UserDefaults key for storing deletion count
    private let photoDeletionCountKey = "swipely_photo_deletion_count"
    
    /// UserDefaults key for storing pro status (test mode)
    private let proStatusKey = "swipely_test_pro_status"
    
    /// Current count of photo deletions
    private(set) var photoDeletionCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: photoDeletionCountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: photoDeletionCountKey)
            objectWillChange.send()
        }
    }
    
    // MARK: - Initialization
    
    static let shared = ProManager()
    
    private init() {
        // Check subscription status on initialization
        checkSubscriptionStatus()
    }
    
    // MARK: - Public Methods
    
    /// Increments photo deletion count and returns whether user has exceeded free limit
    /// - Returns: True if user should see paywall, false otherwise
    func incrementAndCheckPhotoCount() -> Bool {
        // If already pro, no need to check
        if isProUser {
            return false
        }
        
        // Increment count and check if exceeded
        photoDeletionCount += 1
        return photoDeletionCount > freePhotoDeletionLimit
    }
    
    /// Fetches available subscription offerings
    /// - Parameter completion: Callback with offerings and error if any
    func getSubscriptionOfferings(completion: @escaping (Offerings?, Error?) -> Void) {
        // Create mock offerings for test mode
        let monthlyPackage = MockPackage(
            identifier: "monthly",
            packageType: "MONTHLY",
            product: MockProduct(
                identifier: "com.swipely.monthly",
                price: 2.99,
                priceString: "$2.99",
                title: "Monthly Plan"
            ),
            offering: "default"
        )
        
        let yearlyPackage = MockPackage(
            identifier: "yearly",
            packageType: "ANNUAL",
            product: MockProduct(
                identifier: "com.swipely.yearly",
                price: 19.99,
                priceString: "$19.99",
                title: "Yearly Plan"
            ),
            offering: "default"
        )
        
        let currentOffering = MockCurrentOffering(
            monthly: monthlyPackage,
            annual: yearlyPackage
        )
        
        let offerings = MockOfferings(current: currentOffering)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(offerings, nil)
        }
    }
    
    /// Handles purchase of a subscription package
    /// - Parameters:
    ///   - package: The package to purchase
    ///   - completion: Callback with success status and error if any
    func purchasePackage(_ package: Package, completion: @escaping (Bool, Error?) -> Void) {
        // Simulate purchase process with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In test mode, all purchases succeed
            self.isProUser = true
            UserDefaults.standard.set(true, forKey: self.proStatusKey)
            
            // Notify Superwall about the subscription
            NotificationCenter.default.post(
                name: NSNotification.Name("SubscriptionStatusChanged"),
                object: true
            )
            
            completion(true, nil)
        }
    }
    
    /// Restores previous purchases
    /// - Parameter completion: Callback with success status and error if any
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        // In test mode, check if we have stored premium status
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let hasPremium = UserDefaults.standard.bool(forKey: self.proStatusKey)
            if hasPremium {
                self.isProUser = true
                
                // Notify Superwall about the subscription
                NotificationCenter.default.post(
                    name: NSNotification.Name("SubscriptionStatusChanged"),
                    object: true
                )
                
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    /// Resets the photo deletion counter (for testing purposes)
    func resetPhotoCount() {
        photoDeletionCount = 0
    }
    
    /// Resets pro status (for testing purposes)
    func resetProStatus() {
        isProUser = false
        UserDefaults.standard.set(false, forKey: proStatusKey)
        
        // Notify Superwall about the subscription change
        NotificationCenter.default.post(
            name: NSNotification.Name("SubscriptionStatusChanged"),
            object: false
        )
    }
    
    // MARK: - Private Methods
    
    /// Checks current subscription status
    private func checkSubscriptionStatus() {
        // In test mode, just check UserDefaults
        let hasPremium = UserDefaults.standard.bool(forKey: proStatusKey)
        isProUser = hasPremium
    }
} 
