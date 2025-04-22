import SwiftUI

struct ExampleFeatureView: View {
    @State private var showingActionSheet = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pro Features")
                .font(.title)
                .fontWeight(.bold)
            
            // Example pro feature button
            Button(action: {
                // Use the PaywallManager to gate this feature
                PaywallManager.shared.registerFeature(placement: PaywallManager.Placements.batchDelete) {
                    // This code only runs if user has access (after purchase or already subscribed)
                    performBatchDelete()
                }
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Batch Delete")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Example pro feature with params
            Button(action: {
                // Using params to pass contextual data to the paywall
                let params: [String: Any] = [
                    "source": "export_screen",
                    "file_count": 25,
                    "total_size_mb": 128
                ]
                
                PaywallManager.shared.registerFeatureWithParams(
                    placement: PaywallManager.Placements.bulkExport,
                    params: params
                ) {
                    // This code only runs if user has access
                    performBulkExport()
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export All Photos")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Example pro feature
            Button(action: {
                PaywallManager.shared.registerFeature(placement: PaywallManager.Placements.customFilters) {
                    // This code only runs if user has access
                    showCustomFiltersView()
                }
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Custom Filters")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Example pro feature
            Button(action: {
                PaywallManager.shared.registerFeature(placement: PaywallManager.Placements.cloudBackup) {
                    // This code only runs if user has access
                    enableCloudBackup()
                }
            }) {
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                    Text("Cloud Backup")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if isProcessing {
                ProgressView()
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Pro Features")
    }
    
    // These are the actual feature implementations that would run after paywall
    
    private func performBatchDelete() {
        isProcessing = true
        // Simulate batch delete process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            showingActionSheet = true
        }
    }
    
    private func performBulkExport() {
        isProcessing = true
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            // Show success message or UI
        }
    }
    
    private func showCustomFiltersView() {
        // Navigation would happen here
        print("Showing custom filters view")
    }
    
    private func enableCloudBackup() {
        isProcessing = true
        // Simulate enabling cloud backup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            // Show success message or UI
        }
    }
}

#Preview {
    ExampleFeatureView()
} 