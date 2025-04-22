import SwiftUI
import SuperwallKit
// Import only what's needed

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var proManager = ProManager.shared
    
    @State private var selectedPackage: Package?
    @State private var offerings: Offerings?
    @State private var isLoading = true
    @State private var purchaseSuccess = false
    @State private var errorMessage: String?
    
    // MARK: - Constants for test mode
    private let testModeNotice = "✓ Running in test mode - all purchases will automatically succeed"
    
    // Example reasons for the paywall
    var reasonText: String {
        return "Unlock pro features to access unlimited photo organization, advanced filters, and more!"
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.95, green: 0.97, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header area
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Close button
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 20)
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    // Header content
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        Text("Swipely Pro")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(reasonText)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                    }
                }
                .frame(height: 260)
                
                // Features list
                VStack(alignment: .leading, spacing: 18) {
                    PaywallFeatureRow(icon: "infinity", title: "Unlimited Photo Organizing", description: "No more limits on how many photos you can organize")
                    PaywallFeatureRow(icon: "wand.and.stars", title: "Pro Filters", description: "Access to all pro organization filters")
                    PaywallFeatureRow(icon: "icloud.and.arrow.up", title: "Cloud Backup", description: "Secure cloud backup for your photo decisions")
                    PaywallFeatureRow(icon: "bell.badge", title: "Smart Reminders", description: "AI-powered reminders to keep organizing")
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, -20)
                
                // Pricing options
                if isLoading {
                    ProgressView()
                        .padding(.top, 30)
                } else if let offerings = offerings, let currentOffering = offerings.current {
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            // Monthly option
                            PricingOptionView(
                                package: currentOffering.monthly,
                                isSelected: selectedPackage?.identifier == currentOffering.monthly.identifier,
                                onSelect: { selectedPackage = currentOffering.monthly }
                            )
                            
                            // Annual option
                            PricingOptionView(
                                package: currentOffering.annual,
                                isSelected: selectedPackage?.identifier == currentOffering.annual.identifier,
                                onSelect: { selectedPackage = currentOffering.annual },
                                showsSavings: true
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Purchase button
                        Button(action: {
                            if let package = selectedPackage {
                                purchase(package: package)
                            }
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .disabled(selectedPackage == nil)
                        .opacity(selectedPackage == nil ? 0.6 : 1.0)
                        
                        // Restore purchases button
                        Button("Restore Purchases") {
                            restorePurchases()
                        }
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                        .padding(.top, 10)
                        
                        if errorMessage != nil {
                            Text(errorMessage!)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                        
                        // Test mode notice
                        Text(testModeNotice)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.top, 5)
                    }
                } else {
                    Text("Error loading offerings")
                        .foregroundColor(.red)
                        .padding(.top, 30)
                }
                
                Spacer()
                
                // Terms and conditions
                Text("This is a test implementation. In a real app, actual purchases would be processed through Apple's StoreKit.")
                    .font(.system(size: 10))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
            }
            
            // Success overlay
            if purchaseSuccess {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 25) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.green)
                            
                            Text("Thank You!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your purchase was successful. You now have access to all pro features!")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 56)
                                    .background(Color.green)
                                    .cornerRadius(28)
                            }
                            .padding(.top, 10)
                        }
                    )
            }
        }
        .onAppear {
            loadOfferings()
        }
    }
    
    private func loadOfferings() {
        isLoading = true
        proManager.getSubscriptionOfferings { offerings, error in
            isLoading = false
            
            if let offerings = offerings {
                self.offerings = offerings
                // Auto-select the annual option by default
                if let currentOffering = offerings.current {
                    self.selectedPackage = currentOffering.annual
                }
            } else if let error = error {
                self.errorMessage = "Error: \(error.localizedDescription)"
            } else {
                self.errorMessage = "Error loading subscription options"
            }
        }
    }
    
    private func purchase(package: Package) {
        isLoading = true
        proManager.purchasePackage(package) { success, error in
            isLoading = false
            
            if success {
                self.purchaseSuccess = true
            } else if let error = error {
                self.errorMessage = "Purchase failed: \(error.localizedDescription)"
            } else {
                self.errorMessage = "Purchase failed"
            }
        }
    }
    
    private func restorePurchases() {
        isLoading = true
        
        proManager.restorePurchases { success, error in
            isLoading = false
            
            if success {
                self.purchaseSuccess = true
            } else if let error = error {
                self.errorMessage = "Restore failed: \(error.localizedDescription)"
            } else {
                self.errorMessage = "No previous purchases found"
            }
        }
    }
}

// MARK: - Supporting Views

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.darkText))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                    .lineLimit(2)
            }
        }
    }
}

struct PricingOptionView: View {
    let package: Package
    let isSelected: Bool
    let onSelect: () -> Void
    var showsSavings: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Package type
            Text(package.packageType == "MONTHLY" ? "Monthly" : "Yearly")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            // Price
            HStack(alignment: .bottom, spacing: 2) {
                Text(package.product.priceString)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                if package.packageType == "MONTHLY" {
                    Text("/month")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.6))
                } else {
                    Text("/year")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.6))
                }
            }
            
            // Savings tag
            if showsSavings {
                Text("Save 45%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green)
                    .cornerRadius(10)
            } else {
                Spacer()
                    .frame(height: 22)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color(red: 0.9, green: 0.95, blue: 1.0) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color(red: 0.0, green: 0.5, blue: 1.0) : Color(red: 0.8, green: 0.85, blue: 0.9), lineWidth: isSelected ? 2 : 1)
                )
        )
        .onTapGesture {
            onSelect()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
} 