//
//  SettingsView.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import Photos

// Local imports
// No need for explicit imports between Swift files in the same module

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = true
    @State private var autoSaveEnabled = true
    @State private var deleteAfterDays = 30.0
    @State private var showDeleteConfirmation = false
    @State private var developmentTapCount = 0
    @State private var isDeveloperModeEnabled = UserDefaults.standard.bool(forKey: "developerModeEnabled")
    
    // Reference to the shared DeletedPhotoStore
    @ObservedObject var deletedPhotoStore: DeletedPhotoStore
    
    // Colors from the Gen Z aesthetic - matching the app's palette
    let mainColor = Color(hex: "89CFF0")      // Baby blue
    let accentColor1 = Color(hex: "FFD1DC")   // Pastel pink
    let accentColor2 = Color(hex: "B5EAD7")   // Mint green
    let accentColor3 = Color(hex: "FFDAC1")   // Peach
    let accentColor4 = Color(hex: "C7CEEA")   // Periwinkle
    
    var body: some View {
        ZStack {
            // Background with Gen Z aesthetic
            LinearGradient(
                gradient: Gradient(colors: [mainColor.opacity(0.3), mainColor.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                ZStack {
                    // Abstract shapes for Gen Z vibe
                    Circle()
                        .fill(accentColor1.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .offset(x: -150, y: -250)
                    
                    Circle()
                        .fill(accentColor2.opacity(0.2))
                        .frame(width: 250, height: 250)
                        .offset(x: 170, y: 300)
                    
                    Circle()
                        .fill(accentColor4.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .offset(x: 150, y: -320)
                }
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with trendy styling
                VStack(spacing: 16) {
                    HStack {
                        // Back button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(mainColor)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(mainColor.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        // Title
                        Text("Settings")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "5E5CE6"))
                        
                        Spacer()
                        
                        // Placeholder to balance layout
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 16)
                .background(
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Preferences Section
                        SettingsSectionView(title: "App Preferences", icon: "gear", color: mainColor) {
                            // Notifications Toggle
                            ToggleSettingRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                description: "Enable push notifications",
                                isOn: $notificationsEnabled,
                                color: mainColor
                            )
                            
                            Divider().padding(.leading, 56)
                            
                            // Developer Debug Option
                            if isDeveloperModeEnabled {
                                ToggleSettingRow(
                                    icon: "ladybug.fill", 
                                    title: "Developer Debug", 
                                    description: "Toggle developer debug features",
                                    isOn: $isDeveloperModeEnabled,
                                    color: Color(hex: "8A2BE2")
                                )
                                
                                Divider().padding(.leading, 56)
                            }
                        }
                        
                        // Photo Management Section
                        SettingsSectionView(title: "Photo Management", icon: "photo.fill", color: accentColor1) {
                            // Auto-save deleted photos
                            ToggleSettingRow(
                                icon: "arrow.counterclockwise", 
                                title: "Auto-Save", 
                                description: "Automatically store swiped photos",
                                isOn: $autoSaveEnabled,
                                color: accentColor1
                            )
                            
                            Divider().padding(.leading, 56)
                            
                            // Delete after X days slider
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20))
                                        .foregroundColor(accentColor2)
                                        .frame(width: 32)
                                    
                                    Text("Auto Delete")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(deleteAfterDays)) days")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(accentColor2)
                                }
                                .padding(.horizontal, 12)
                                
                                Slider(value: $deleteAfterDays, in: 7...90, step: 1)
                                    .accentColor(accentColor2)
                                    .padding(.horizontal, 12)
                                
                                Text("Photos will be permanently deleted after this period")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.leading, 44)
                            }
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(16)
                        }
                        
                        // Account Actions Section
                        SettingsSectionView(title: "Account", icon: "person.fill", color: accentColor3) {
                            // Pro Features Button
                            NavigationLink(destination: ExampleFeatureView()) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(accentColor3)
                                        .frame(width: 32)
                                    
                                    Text("Pro Features")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 56)
                            
                            // Manage Subscription Button
                            Button(action: {
                                // Open subscription management
                                if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(accentColor4)
                                        .frame(width: 32)
                                    
                                    Text("Manage Subscription")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            // Clear All Data Button
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "FF5F6D"))
                                        .frame(width: 32)
                                    
                                    Text("Clear All Data")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            // Support & Help
                            NavigationLink(destination: Text("Support Center - Coming Soon")) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(mainColor)
                                        .frame(width: 32)
                                    
                                    Text("Help & Support")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // App Info Section
                        SettingsSectionView(title: "About", icon: "info.circle.fill", color: accentColor4) {
                            // Version Info
                            HStack {
                                Image(systemName: "number")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor4)
                                    .frame(width: 32)
                                
                                Text("App Version")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.gray)
                                    .onTapGesture {
                                        // Secret tap to enable developer mode
                                        developmentTapCount += 1
                                        
                                        // If tapped 7 times, toggle developer mode
                                        if developmentTapCount >= 7 {
                                            isDeveloperModeEnabled.toggle()
                                            UserDefaults.standard.set(isDeveloperModeEnabled, forKey: "developerModeEnabled")
                                            developmentTapCount = 0
                                            
                                            // Provide feedback
                                            let notification = UINotificationFeedbackGenerator()
                                            notification.notificationOccurred(.success)
                                        } else if developmentTapCount > 3 {
                                            // Provide subtle feedback for progress
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                        }
                                    }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(16)
                            
                            Divider().padding(.leading, 56)
                            
                            // Privacy Policy Link
                            Button(action: {
                                // Open privacy policy page or link
                            }) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(accentColor1)
                                        .frame(width: 32)
                                    
                                    Text("Privacy Policy")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                        }
                        
                        // Developer Debug Section - Only shown when enabled
                        if isDeveloperModeEnabled {
                            SettingsSectionView(title: "Developer Debug", icon: "hammer.fill", color: Color(hex: "8A2BE2")) {
                                // Restart Onboarding Button
                                Button(action: {
                                    // Reset the onboarding completion state
                                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                                    
                                    // Create a notification that SwipelyApp will listen for
                                    NotificationCenter.default.post(name: NSNotification.Name("RestartOnboarding"), object: nil)
                                    
                                    // Show alert or feedback that onboarding has been reset
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    // Exit the app
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            exit(0)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.counterclockwise.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "8A2BE2"))
                                            .frame(width: 32)
                                        
                                        Text("Restart Onboarding")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray.opacity(0.7))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                // Clear App Cache
                                Button(action: {
                                    // Clear app cache
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    // Clear the image cache
                                    URLCache.shared.removeAllCachedResponses()
                                    PHCachingImageManager().stopCachingImagesForAllAssets()
                                }) {
                                    HStack {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "8A2BE2"))
                                            .frame(width: 32)
                                        
                                        Text("Clear App Cache")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray.opacity(0.7))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                // Reset Photo Selection
                                Button(action: {
                                    // Reset the photo group selection state
                                    UserDefaults.standard.set(false, forKey: "hasSelectedPhotoGroup")
                                    
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }) {
                                    HStack {
                                        Image(systemName: "photo.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "8A2BE2"))
                                            .frame(width: 32)
                                        
                                        Text("Reset Photo Selection")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray.opacity(0.7))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                // Force Refresh Photos
                                Button(action: {
                                    // Force refresh the photo library in a safer way
                                    let phManager = PHCachingImageManager()
                                    phManager.stopCachingImagesForAllAssets()
                                    
                                    // Reset any photo-related app states
                                    NotificationCenter.default.post(name: NSNotification.Name("ForcePhotoRefresh"), object: nil)
                                    
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    // Notify user of refresh
                                    let notification = UINotificationFeedbackGenerator()
                                    notification.notificationOccurred(.success)
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "8A2BE2"))
                                            .frame(width: 32)
                                        
                                        Text("Force Refresh Photos")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray.opacity(0.7))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                // Import/Export Settings
                                Button(action: {
                                    // This is just a placeholder for an import/export feature
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    // In a real implementation, this would show an action sheet with options
                                    // to import settings from a file or export current settings to a file
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up.on.square.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "8A2BE2"))
                                            .frame(width: 32)
                                        
                                        Text("Import/Export Settings")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray.opacity(0.7))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                // Show App Build Info
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "8A2BE2"))
                                        .frame(width: 32)
                                    
                                    Text("Build Info")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Build: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown")")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.gray)
                                        
                                        Text("Build Date: \(Date().formatted(date: .abbreviated, time: .shortened))")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }
            
            // Delete All Confirmation
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "FF5F6D"))
                            
                            Text("Clear All Data?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "5E5CE6"))
                            
                            Text("This will permanently delete all your saved photos and reset the app. This action cannot be undone.")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                showDeleteConfirmation = false
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(mainColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(mainColor, lineWidth: 1)
                                            )
                                    )
                            }
                            
                            Button(action: {
                                // Clear all data action
                                deletedPhotoStore.deletedPhotos.removeAll()
                                showDeleteConfirmation = false
                            }) {
                                Text("Delete")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(hex: "FF5F6D"), Color(hex: "FF9A8B")]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
                    .padding(24)
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Component Views

struct SettingsSectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "5E5CE6"))
            }
            .padding(.horizontal, 12)
            
            // Content
            VStack(spacing: 2) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.3))
                    .shadow(color: color.opacity(0.15), radius: 15, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

struct ToggleSettingRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .labelsHidden()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(16)
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(deletedPhotoStore: DeletedPhotoStore())
    }
}
