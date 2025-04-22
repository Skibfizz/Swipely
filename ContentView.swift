//
//  ContentView.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import Photos
import UIKit
import SuperwallKit
import StoreKit

// Create a shared model to store deleted photos
class DeletedPhotoStore: ObservableObject {
    @Published var deletedPhotos: [MarkedPhoto] = []
    
    func addPhoto(id: String, image: UIImage, date: Date, assetLocalIdentifier: String? = nil) {
        deletedPhotos.append(MarkedPhoto(id: id, image: image, date: date, assetLocalIdentifier: assetLocalIdentifier))
    }
    
    func removePhoto(withId id: String) {
        deletedPhotos.removeAll { $0.id == id }
    }
}

// Custom text style modifier to avoid font ambiguity
struct TextStyle: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .environment(\.font, .system(size: size, weight: weight))
    }
}

extension View {
    func textStyle(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(TextStyle(size: size, weight: weight))
    }
}

// App theme colors
struct AppColors {
    static let primary = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let background = Color(red: 0.95, green: 0.97, blue: 1.0)
    static let card = Color.white
    static let delete = Color(red: 0.9, green: 0.2, blue: 0.3)
    static let keep = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let text = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let secondaryText = Color(red: 0.5, green: 0.55, blue: 0.6)
}

struct ContentView: View {
    @State private var currentImageIndex = 0
    @State private var totalImages = 9
    @State private var markedForDeletion = 1
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var showDeleteOverlay = false
    @State private var showKeepOverlay = false
    @State private var showPhotoGroupSelection = false
    @State private var selectedPhotos: [PHAsset] = []
    @State private var hasSelectedPhotoGroup = false
    @State private var currentImage: UIImage? = nil
    @State private var showDeletePage = false
    @State private var showSettings = false
    @State private var showProFeatures = false
    
    // Add subscription status state
    @State private var isProSubscriber = false
    
    // Add shared deletion store
    @StateObject private var deletedPhotoStore = DeletedPhotoStore()
    
    // Baby blue as main color with complementary Gen Z palette
    let mainColor = Color(hex: "89CFF0")      // Baby blue
    let accentColor1 = Color(hex: "FFD1DC")   // Pastel pink
    let accentColor2 = Color(hex: "B5EAD7")   // Mint green
    let accentColor3 = Color(hex: "FFDAC1")   // Peach
    let accentColor4 = Color(hex: "C7CEEA")   // Periwinkle
    
    private let imageManager = PHCachingImageManager()
    
    var body: some View {
        ZStack {
            // Fun Gen Z background with baby blue gradient
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
            
            VStack(spacing: 16) {
                // Top status bar with trendy styling
                HStack {
                    // Trash counter with holographic effect
                    Button(action: {
                        showDeletePage = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(mainColor)
                                .font(.system(size: 16, weight: .bold))
                            Text("\(markedForDeletion)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "5E5CE6"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(mainColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [mainColor.opacity(0.5), accentColor1.opacity(0.5)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                    
                    Spacer()
                    
                    // Counter with Y2K-inspired pill
                    Button(action: {
                        showPhotoGroupSelection = true
                    }) {
                        HStack(spacing: 6) {
                            Text("\(currentImageIndex + 1) of \(selectedPhotos.isEmpty ? totalImages : selectedPhotos.count)")
                                .font(.system(size: 15, weight: .medium))
                            Image(systemName: "photo.fill")
                                .foregroundColor(mainColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [mainColor.opacity(0.5), accentColor4.opacity(0.5)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                    
                    Spacer()
                    
                    // Pro Features button with star icon
                    Button(action: {
                        showProFeatures = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [accentColor1.opacity(0.3), accentColor3.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [accentColor1.opacity(0.6), accentColor3.opacity(0.6)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "FFD700"))
                                .font(.system(size: 18))
                        }
                    }
                    
                    Spacer(minLength: 8)
                    
                    // Settings button with cool effect
                    Button(action: {
                        showSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [mainColor.opacity(0.3), accentColor4.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [mainColor.opacity(0.6), accentColor4.opacity(0.6)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color(hex: "5E5CE6"))
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Main image card with Gen Z styling
                ZStack {
                    // Image card with trendy border and effects
                    ZStack {
                        // Image container with cool border
                        if hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                            if let currentImage = currentImage {
                                Image(uiImage: currentImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        mainColor,
                                                        accentColor1,
                                                        accentColor2,
                                                        accentColor3,
                                                        accentColor4
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: mainColor.opacity(0.4), radius: 15, x: 0, y: 8)
                            } else {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(mainColor)
                            }
                        } else {
                            Image("currentImage") // Replace with your image loading logic
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    mainColor,
                                                    accentColor1,
                                                    accentColor2,
                                                    accentColor3,
                                                    accentColor4
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: mainColor.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        
                        // Delete overlay with Gen Z style
                        if showDeleteOverlay {
                            VStack {
                                Text("NOPE")
                                    .font(.system(size: 42, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "FF5F6D"), Color(hex: "FF9A8B")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(10)
                                    .rotationEffect(.degrees(-15))
                                    .opacity(0.9)
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(30)
                        }
                        
                        // Keep overlay with Gen Z style
                        if showKeepOverlay {
                            VStack {
                                Text("KEEP")
                                    .font(.system(size: 42, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [accentColor2, mainColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(10)
                                    .rotationEffect(.degrees(15))
                                    .opacity(0.9)
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(30)
                        }
                    }
                    .offset(cardOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                // Check if user is pro subscriber before allowing swipe
                                if !isProSubscriber {
                                    // Reset any ongoing gesture
                                    cardOffset = .zero
                                    cardRotation = 0
                                    showDeleteOverlay = false
                                    showKeepOverlay = false
                                    
                                    // Show paywall when user tries to swipe
                                    Superwall.shared.register(placement: "swipe_feature") {
                                        // This code only runs if the user gets access (subscribes or paywall is configured to allow access)
                                        handleSwipe(gesture)
                                    }
                                    return
                                }
                                
                                // Only proceed with swipe if user is a pro subscriber
                                handleSwipe(gesture)
                            }
                            .onEnded { gesture in
                                // Check subscription status again to be safe
                                if !isProSubscriber {
                                    // Reset any ongoing gesture
                                    cardOffset = .zero
                                    cardRotation = 0
                                    showDeleteOverlay = false
                                    showKeepOverlay = false
                                    
                                    // Show paywall when user tries to complete swipe
                                    Superwall.shared.register(placement: "swipe_complete") {
                                        // This code only runs if the user gets access
                                        handleSwipeEnd(gesture)
                                    }
                                    return
                                }
                                
                                // Original swipe logic for pro subscribers
                                handleSwipeEnd(gesture)
                            }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom action buttons with Gen Z styling
                HStack(spacing: 60) {
                    // Delete button with trendy styling
                    Button(action: {
                        // Check if user is pro subscriber
                        if !isProSubscriber {
                            // Show paywall when non-subscriber tries to delete
                            Superwall.shared.register(placement: "delete_feature") {
                                // This code only runs if the user gets access
                                handleDeleteAction()
                            }
                            return
                        }
                        
                        // Delete action for pro subscribers
                        handleDeleteAction()
                    }) {
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [accentColor1.opacity(0.7), accentColor1.opacity(0.0)]),
                                        center: .center,
                                        startRadius: 25,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 90, height: 90)
                            
                            // Button background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 65, height: 65)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [accentColor1.opacity(0.8), accentColor1.opacity(0.3)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            
                            // Icon
                            Image(systemName: "trash.fill")
                                .font(.system(size: 26))
                                .foregroundColor(accentColor1)
                        }
                    }
                    
                    // Keep button with trendy styling
                    Button(action: {
                        // Check if user is pro subscriber
                        if !isProSubscriber {
                            // Show paywall when non-subscriber tries to keep
                            Superwall.shared.register(placement: "keep_feature") {
                                // This code only runs if the user gets access
                                handleKeepAction()
                            }
                            return
                        }
                        
                        // Keep action for pro subscribers
                        handleKeepAction()
                    }) {
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [mainColor.opacity(0.7), mainColor.opacity(0.0)]),
                                        center: .center,
                                        startRadius: 25,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 90, height: 90)
                            
                            // Button background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 65, height: 65)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [mainColor.opacity(0.8), mainColor.opacity(0.3)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            
                            // Icon
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(mainColor)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showPhotoGroupSelection) {
            PhotoGroupSelectionView(
                selectedPhotos: $selectedPhotos,
                showGroupSelection: $showPhotoGroupSelection,
                hasSelectedPhotoGroup: $hasSelectedPhotoGroup
            )
        }
        .sheet(isPresented: $showDeletePage) {
            DeletePageView(deletedPhotoStore: deletedPhotoStore)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(deletedPhotoStore: deletedPhotoStore)
        }
        .sheet(isPresented: $showProFeatures) {
            ExampleFeatureView()
        }
        .onChange(of: selectedPhotos) { photos in
            totalImages = photos.count
            if !photos.isEmpty {
                currentImageIndex = 0
                loadCurrentImage()
            }
        }
        .onChange(of: currentImageIndex) { _ in
            loadCurrentImage()
        }
        .onAppear {
            // Check subscription status from StoreKit
            checkSubscriptionStatus()
            
            // Load initial image if available
            loadCurrentImage()
        }
    }
    
    private func loadCurrentImage() {
        guard hasSelectedPhotoGroup, !selectedPhotos.isEmpty, currentImageIndex < selectedPhotos.count else {
            return
        }
        
        let asset = selectedPhotos[currentImageIndex]
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 600, height: 600),
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            if let image = image {
                self.currentImage = image
            }
        }
    }
    
    // Helper methods for swipe actions
    private func handleSwipe(_ gesture: DragGesture.Value) {
        cardOffset = gesture.translation
        cardRotation = Double(gesture.translation.width / 20)
        
        // Show overlays based on drag direction
        showDeleteOverlay = gesture.translation.width < -40
        showKeepOverlay = gesture.translation.width > 40
    }
    
    private func handleSwipeEnd(_ gesture: DragGesture.Value) {
        if gesture.translation.width < -100 {
            // Swipe left to delete
            withAnimation(.spring()) {
                cardOffset = CGSize(width: -500, height: 0)
                markedForDeletion += 1
                
                // Save the current photo to the deleted photos store
                if let currentImage = currentImage, hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                    let asset = selectedPhotos[currentImageIndex]
                    let uniqueId = asset.localIdentifier
                    let date = asset.creationDate ?? Date()
                    deletedPhotoStore.addPhoto(id: uniqueId, image: currentImage, date: date, assetLocalIdentifier: uniqueId)
                }
            }
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cardOffset = .zero
                cardRotation = 0
                showDeleteOverlay = false
                
                if hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                    if currentImageIndex < selectedPhotos.count - 1 {
                        currentImageIndex += 1
                    } else {
                        currentImageIndex = 0
                    }
                } else {
                    currentImageIndex = (currentImageIndex + 1) % totalImages
                }
            }
        } else if gesture.translation.width > 100 {
            // Swipe right to keep
            withAnimation(.spring()) {
                cardOffset = CGSize(width: 500, height: 0)
            }
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cardOffset = .zero
                cardRotation = 0
                showKeepOverlay = false
                
                if hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                    if currentImageIndex < selectedPhotos.count - 1 {
                        currentImageIndex += 1
                    } else {
                        currentImageIndex = 0
                    }
                } else {
                    currentImageIndex = (currentImageIndex + 1) % totalImages
                }
            }
        } else {
            // Return to center if not swiped enough
            withAnimation(.spring()) {
                cardOffset = .zero
                cardRotation = 0
                showDeleteOverlay = false
                showKeepOverlay = false
            }
        }
    }
    
    private func handleDeleteAction() {
        withAnimation(.spring()) {
            cardOffset = CGSize(width: -500, height: 0)
            markedForDeletion += 1
            
            // Save the current photo to the deleted photos store
            if let currentImage = currentImage, hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                let asset = selectedPhotos[currentImageIndex]
                let uniqueId = asset.localIdentifier
                let date = asset.creationDate ?? Date()
                deletedPhotoStore.addPhoto(id: uniqueId, image: currentImage, date: date, assetLocalIdentifier: uniqueId)
            }
        }
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardOffset = .zero
            cardRotation = 0
            
            if hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                if currentImageIndex < selectedPhotos.count - 1 {
                    currentImageIndex += 1
                } else {
                    currentImageIndex = 0
                }
            } else {
                currentImageIndex = (currentImageIndex + 1) % totalImages
            }
        }
    }
    
    private func handleKeepAction() {
        withAnimation(.spring()) {
            cardOffset = CGSize(width: 500, height: 0)
        }
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardOffset = .zero
            cardRotation = 0
            
            if hasSelectedPhotoGroup && !selectedPhotos.isEmpty {
                if currentImageIndex < selectedPhotos.count - 1 {
                    currentImageIndex += 1
                } else {
                    currentImageIndex = 0
                }
            } else {
                currentImageIndex = (currentImageIndex + 1) % totalImages
            }
        }
    }
    
    // Update the subscription status check method
    private func checkSubscriptionStatus() {
        // This is where you'd check if the user has an active subscription
        // Example using StoreKit:
        // let isSubscribed = YourStoreKitManager.hasActiveSubscription()
        // isProSubscriber = isSubscribed
        
        // Important: Update Superwall's subscription status
        if UserDefaults.standard.bool(forKey: "hasSubscribed") {
            // If user is subscribed:
            Superwall.shared.subscriptionStatus = .active([]) // For v4+, pass an empty array or product IDs
        } else {
            // If user is not subscribed:
            Superwall.shared.subscriptionStatus = .inactive
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
