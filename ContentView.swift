//
//  ContentView.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import Photos
import UIKit

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
    @State private var photos: [PHAsset] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showPermissionAlert = false
    @State private var permissionStatus: PHAuthorizationStatus = .notDetermined
    @State private var setupError: String? = nil
    @State private var recycledPhotos: [PHAsset] = []
    @State private var showingRecycleBin = false
    @State private var photoOpacity: Double = 1.0
    @State private var showingSettings = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // Background
            AppColors.background.ignoresSafeArea()
            
            if let error = setupError {
                // Error View
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                    
                    Text("Setup Required")
                        .textStyle(size: 28, weight: .bold)
                        .foregroundColor(AppColors.text)
                    
                    Text(error)
                        .textStyle(size: 17)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(AppColors.text)
                    
                    Text("This app requires permissions to be set in Info.plist.")
                        .textStyle(size: 15)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.top, 5)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.card)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
            } else if permissionStatus == .notDetermined || permissionStatus == .denied || permissionStatus == .restricted {
                // Welcome / Permission View
                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: "photo.stack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Text("Welcome to Swipely")
                        .textStyle(size: 30, weight: .bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Swipe left to delete photos or right to keep them")
                        .textStyle(size: 17)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(AppColors.secondaryText)
                    
                    if permissionStatus == .notDetermined {
                        Button("Get Started") {
                            requestPhotoAccess()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        Button("Open Settings") {
                            openSettings()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Photo access denied. Please grant access in Settings.")
                            .textStyle(size: 15)
                            .foregroundColor(AppColors.delete)
                            .padding(.top, 5)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.card)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
            } else if photos.isEmpty {
                // No Photos View
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray)
                    }
                    
                    Text("No Photos Found")
                        .textStyle(size: 28, weight: .bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Your photo library appears to be empty")
                        .textStyle(size: 17)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.card)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
            } else if currentIndex < photos.count {
                // Main Swiping View
                ZStack {
                    // Current photo - adding a key to force refresh
                    PhotoView(asset: photos[currentIndex])
                        .id(photos[currentIndex].localIdentifier) // Force refresh when photo changes
                        .offset(offset)
                        .rotationEffect(.degrees(Double(offset.width) / 20.0))
                        .opacity(photoOpacity)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                }
                                .onEnded { gesture in
                                    handleSwipe(with: gesture)
                                }
                        )
                    
                    // Action labels overlay on drag
                    if offset.width < -40 {
                        VStack {
                            Spacer()
                            Text("DELETE")
                                .textStyle(size: 20, weight: .bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(AppColors.delete)
                                .cornerRadius(8)
                                .opacity(min(1.0, Double(abs(offset.width)) / 120.0))
                                .rotationEffect(.degrees(8))
                                .padding(.bottom, 140)
                                .padding(.leading, 40)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else if offset.width > 40 {
                        VStack {
                            Spacer()
                            Text("KEEP")
                                .textStyle(size: 20, weight: .bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(AppColors.keep)
                                .cornerRadius(8)
                                .opacity(min(1.0, Double(abs(offset.width)) / 120.0))
                                .rotationEffect(.degrees(-8))
                                .padding(.bottom, 140)
                                .padding(.trailing, 40)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                // UI Controls
                VStack {
                    HStack {
                        Button(action: {
                            showingRecycleBin = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .imageScale(.medium)
                                Text("\(recycledPhotos.count)")
                                    .textStyle(size: 15, weight: .semibold)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(recycledPhotos.isEmpty ? Color.gray.opacity(0.2) : AppColors.primary.opacity(0.2))
                            .foregroundColor(recycledPhotos.isEmpty ? Color.gray : AppColors.primary)
                            .cornerRadius(20)
                        }
                        .opacity(recycledPhotos.isEmpty ? 0.5 : 1.0)
                        .disabled(recycledPhotos.isEmpty)
                        
                        Spacer()
                        
                        Text("\(currentIndex + 1) of \(photos.count)")
                            .textStyle(size: 15, weight: .medium)
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                                .imageScale(.medium)
                                .padding(10)
                                .background(Color.black.opacity(0.05))
                                .foregroundColor(AppColors.text)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    HStack(spacing: 80) {
                        // Delete indicator
                        ZStack {
                            Circle()
                                .fill(AppColors.delete.opacity(offset.width < 0 ? 0.2 : 0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(offset.width < -40 ? AppColors.delete : Color.gray.opacity(0.5))
                        }
                        
                        // Keep indicator
                        ZStack {
                            Circle()
                                .fill(AppColors.keep.opacity(offset.width > 0 ? 0.2 : 0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.bottom, 40)
                }
            } else {
                // End of Photos View
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Text("All Done!")
                        .textStyle(size: 28, weight: .bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("No more photos to review")
                        .textStyle(size: 17)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Button("Start Over") {
                        loadPhotos()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.top, 8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.card)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
            }
        }
        .alert("Photo Access Required", isPresented: $showPermissionAlert) {
            Button("Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Swipely needs access to your photos to help you manage them. Please grant access in Settings.")
        }
        .sheet(isPresented: $showingRecycleBin) {
            RecycleBinView(recycledPhotos: $recycledPhotos)
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                List {
                    Section(header: Text("Preferences")) {
                        Button(action: {
                            // Reset onboarding flag
                            hasCompletedOnboarding = false
                            showingSettings = false
                        }) {
                            HStack {
                                Text("Reset Onboarding")
                                    .foregroundColor(AppColors.text)
                                Spacer()
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        
                        Button(action: {
                            openSettings()
                        }) {
                            HStack {
                                Text("Photo Permissions")
                                    .foregroundColor(AppColors.text)
                                Spacer()
                                Image(systemName: "photo")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppColors.text)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingSettings = false
                        }
                        .textStyle(size: 17, weight: .medium)
                        .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .onAppear {
            safeCheckPhotoAuthorization()
        }
    }
    
    private func safeCheckPhotoAuthorization() {
        // Get photo library authorization status
        let status = PHPhotoLibrary.authorizationStatus()
        self.permissionStatus = status
        
        // Check if Info.plist has required keys
        guard let infoDictionary = Bundle.main.infoDictionary else {
            setupError = "Unable to access app's Info.plist"
            return
        }
        
        if infoDictionary["NSPhotoLibraryUsageDescription"] == nil {
            setupError = "Your app's Info.plist must include NSPhotoLibraryUsageDescription key. Please add this key in Xcode under your target's Info tab."
            return
        }
        
        switch status {
        case .authorized, .limited:
            loadPhotos()
        case .notDetermined:
            // Wait for user to tap button
            break
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            setupError = "Unknown photo library permission status"
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.permissionStatus = status
                if status == .authorized || status == .limited {
                    self.loadPhotos()
                } else if status == .denied || status == .restricted {
                    self.showPermissionAlert = true
                }
            }
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        self.photos = assets
        self.currentIndex = 0
    }
    
    private func handleSwipe(with gesture: DragGesture.Value) {
        let threshold: CGFloat = 100
        
        if gesture.translation.width > threshold {
            // Swiped right - keep photo
            withAnimation {
                offset = CGSize(width: 500, height: 0)
                photoOpacity = 0
            }
            
            // Simply move to next photo after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.currentIndex < self.photos.count {
                    self.currentIndex += 1
                    self.offset = .zero
                    
                    // Fade in the new photo
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.photoOpacity = 1.0
                    }
                }
            }
        } else if gesture.translation.width < -threshold {
            // Swiped left - delete photo
            withAnimation {
                offset = CGSize(width: -500, height: 0)
                photoOpacity = 0
            }
            
            // Delete current photo and reset offset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.currentIndex < self.photos.count {
                    // Get the photo to delete
                    let assetToDelete = self.photos[self.currentIndex]
                    
                    // Add to recycling bin
                    self.recycledPhotos.append(assetToDelete)
                    
                    // Remove from photos array
                    self.photos.remove(at: self.currentIndex)
                    
                    // Reset offset
                    self.offset = .zero
                    
                    // Fade in the new photo
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.photoOpacity = 1.0
                    }
                }
            }
        } else {
            // Return to center
            withAnimation {
                offset = .zero
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct PhotoView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 80)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 5)
            } else {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.height * 0.6)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .highQualityFormat
        option.resizeMode = .exact
        
        manager.requestImage(for: asset, 
                            targetSize: CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2), 
                            contentMode: .aspectFit, 
                            options: option) { result, info in
            if let image = result {
                self.image = image
            }
        }
    }
}

struct RecycleBinView: View {
    @Binding var recycledPhotos: [PHAsset]
    @State private var selectedPhotos = Set<String>()
    @State private var isDeleting = false
    @State private var deletionComplete = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack {
                    if recycledPhotos.isEmpty {
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 130, height: 130)
                                
                                Image(systemName: "trash.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Recycle Bin is Empty")
                                .textStyle(size: 28, weight: .bold)
                                .foregroundColor(AppColors.text)
                            
                            Text("Photos you mark for deletion will appear here")
                                .textStyle(size: 17)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.card)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(24)
                    } else {
                        // Selection header
                        HStack {
                            Button(action: {
                                selectedPhotos = Set(recycledPhotos.map { $0.localIdentifier })
                            }) {
                                Text("Select All")
                                    .textStyle(size: 15, weight: .medium)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(AppColors.primary.opacity(0.1))
                                    .foregroundColor(AppColors.primary)
                                    .cornerRadius(16)
                            }
                            
                            Spacer()
                            
                            if !selectedPhotos.isEmpty {
                                Text("\(selectedPhotos.count) selected")
                                    .textStyle(size: 15, weight: .medium)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedPhotos.removeAll()
                            }) {
                                Text("Clear")
                                    .textStyle(size: 15, weight: .medium)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundColor(Color.gray)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Grid of photos
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 16)], spacing: 16) {
                                ForEach(recycledPhotos, id: \.localIdentifier) { asset in
                                    RecycledPhotoItem(asset: asset, isSelected: selectedPhotos.contains(asset.localIdentifier)) {
                                        toggleSelection(asset)
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        // Delete button
                        Button(action: {
                            deleteSelectedPhotos()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Selected (\(selectedPhotos.count))")
                            }
                            .textStyle(size: 17, weight: .semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedPhotos.isEmpty ? Color.gray.opacity(0.3) : AppColors.delete)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: selectedPhotos.isEmpty ? Color.clear : AppColors.delete.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(selectedPhotos.isEmpty)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Recycle Bin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .textStyle(size: 17, weight: .medium)
                    .foregroundColor(AppColors.primary)
                }
            }
            .overlay {
                if isDeleting {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.bottom, 8)
                            
                            Text("Deleting photos...")
                                .textStyle(size: 17, weight: .medium)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.8))
                        )
                    }
                }
            }
            .alert("Photos Deleted", isPresented: $deletionComplete) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Selected photos have been permanently deleted.")
            }
        }
    }
    
    private func toggleSelection(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if selectedPhotos.contains(id) {
            selectedPhotos.remove(id)
        } else {
            selectedPhotos.insert(id)
        }
    }
    
    private func deleteSelectedPhotos() {
        let photosToDelete = recycledPhotos.filter { selectedPhotos.contains($0.localIdentifier) }
        if photosToDelete.isEmpty { return }
        
        isDeleting = true
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(photosToDelete as NSArray)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                isDeleting = false
                
                if success {
                    // Remove deleted photos from the recycling bin
                    recycledPhotos.removeAll { selectedPhotos.contains($0.localIdentifier) }
                    selectedPhotos.removeAll()
                    deletionComplete = true
                } else {
                    print("Error deleting photos: \(String(describing: error))")
                }
            }
        }
    }
}

struct RecycledPhotoItem: View {
    let asset: PHAsset
    let isSelected: Bool
    let onTap: () -> Void
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 110, height: 110)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                        )
                }
            }
            .frame(width: 110, height: 110)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 3)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(AppColors.primary)
                }
                .padding(6)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .opportunistic
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: option
        ) { result, _ in
            if let image = result {
                self.image = image
            }
        }
    }
}

#Preview {
    ContentView()
}
