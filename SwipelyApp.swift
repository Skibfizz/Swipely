//
//  SwipelyApp.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI

@main
struct SwipelyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        // Add permission descriptions to Info.plist at runtime
        if let infoDictionary = Bundle.main.infoDictionary {
            // Check if the key doesn't already exist
            if infoDictionary["NSPhotoLibraryUsageDescription"] == nil {
                // This is a workaround, actual Info.plist keys should be set in project settings
                print("Note: Photo Library permission descriptions should be added to Info.plist")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
