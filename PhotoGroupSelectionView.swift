//
//  PhotoGroupSelectionView.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import Photos

// MARK: - Models

struct PhotoGroup: Identifiable {
    let id = UUID()
    let date: Date
    let month: String
    let year: String
    let photos: [PHAsset]
    let thumbnail: UIImage?
}

// MARK: - Photo Manager

class PhotoManager: ObservableObject {
    @Published var photoGroups: [PhotoGroup] = []
    @Published var isLoading = false
    @Published var hasPermission = false
    
    private let imageManager = PHCachingImageManager()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            hasPermission = true
            fetchPhotoGroups()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    self?.hasPermission = status == .authorized || status == .limited
                    if self?.hasPermission == true {
                        self?.fetchPhotoGroups()
                    }
                }
            }
        default:
            hasPermission = false
        }
    }
    
    func fetchPhotoGroups() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Fetch all photos sorted by creation date
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var groups: [String: [PHAsset]] = [:]
            var thumbnails: [String: UIImage] = [:]
            let dateFormatter = DateFormatter()
            let monthFormatter = DateFormatter()
            let yearFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM"
            monthFormatter.dateFormat = "MMMM"
            yearFormatter.dateFormat = "yyyy"
            
            // Group photos by month and year
            for i in 0..<allPhotos.count {
                let asset = allPhotos.object(at: i)
                if let creationDate = asset.creationDate {
                    let key = dateFormatter.string(from: creationDate)
                    
                    if groups[key] == nil {
                        groups[key] = []
                        
                        // Generate thumbnail for the first photo in each group
                        let targetSize = CGSize(width: 200, height: 200)
                        self.imageManager.requestImage(
                            for: asset,
                            targetSize: targetSize,
                            contentMode: .aspectFill,
                            options: nil
                        ) { image, _ in
                            if let image = image {
                                thumbnails[key] = image
                            }
                        }
                    }
                    
                    groups[key]?.append(asset)
                }
            }
            
            // Convert to PhotoGroup objects
            var photoGroups: [PhotoGroup] = []
            
            for (key, assets) in groups {
                if let date = dateFormatter.date(from: key) {
                    let month = monthFormatter.string(from: date)
                    let year = yearFormatter.string(from: date)
                    
                    photoGroups.append(
                        PhotoGroup(
                            date: date,
                            month: month,
                            year: year,
                            photos: assets,
                            thumbnail: thumbnails[key]
                        )
                    )
                }
            }
            
            // Sort by date (most recent first)
            photoGroups.sort { $0.date > $1.date }
            
            DispatchQueue.main.async {
                self.photoGroups = photoGroups
                self.isLoading = false
            }
        }
    }
    
    func loadImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        imageManager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: nil
        ) { image, _ in
            completion(image)
        }
    }
}

// MARK: - Main View

struct PhotoGroupsView: View {
    @StateObject private var photoManager = PhotoManager()
    @State private var selectedGroup: PhotoGroup? = nil
    var onGroupSelected: ([PHAsset]) -> Void
    var onDismiss: () -> Void
    
    // Colors from the Gen Z aesthetic
    let mainColor = Color(hex: "89CFF0")      // Baby blue
    let accentColor1 = Color(hex: "FFD1DC")   // Pastel pink
    let accentColor2 = Color(hex: "B5EAD7")   // Mint green
    let accentColor3 = Color(hex: "FFDAC1")   // Peach
    let accentColor4 = Color(hex: "C7CEEA")   // Periwinkle
    
    var body: some View {
        ZStack {
            // Background with Gen Z aesthetic
            LinearGradient(
                gradient: Gradient(colors: [mainColor.opacity(0.2), mainColor.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                ZStack {
                    Circle()
                        .fill(accentColor1.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .offset(x: -150, y: -250)
                    
                    Circle()
                        .fill(accentColor2.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .offset(x: 170, y: 300)
                    
                    Circle()
                        .fill(accentColor4.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .offset(x: 150, y: -320)
                }
            )
            .ignoresSafeArea()
            
            VStack {
                // Header with trendy styling
                HStack {
                    Button(action: {
                        onDismiss()
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
                    
                    Text("Photo Groups")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "5E5CE6"))
                    
                    Spacer()
                    
                    Button(action: {
                        photoManager.fetchPhotoGroups()
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
                                .frame(width: 40, height: 40)
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
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color(hex: "5E5CE6"))
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if photoManager.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(mainColor)
                        .padding()
                    Text("Loading your photos...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.gray)
                    Spacer()
                } else if !photoManager.hasPermission {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor)
                        
                        Text("Photo Access Required")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "5E5CE6"))
                        
                        Text("Please allow access to your photos to use this feature")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Open Settings")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [mainColor, accentColor4]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    Spacer()
                } else if photoManager.photoGroups.isEmpty {
                    Spacer()
                    Text("No photos found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.gray)
                    Spacer()
                } else {
                    // Month/Year Groups
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(photoManager.photoGroups) { group in
                                PhotoGroupCard(group: group, mainColor: mainColor, accentColors: [accentColor1, accentColor2, accentColor3, accentColor4]) {
                                    // When a group is selected, pass its photos to the main app
                                    onGroupSelected(group.photos)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Photo Group Card

struct PhotoGroupCard: View {
    let group: PhotoGroup
    let mainColor: Color
    let accentColors: [Color]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with month and year
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.month)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "5E5CE6"))
                        
                        Text(group.year)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(group.photos.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [mainColor, accentColors[3]]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Single thumbnail preview instead of grid
                if !group.photos.isEmpty {
                    PhotoThumbnail(asset: group.photos[0], size: CGSize(width: 280, height: 200))
                        .frame(height: 200)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 3)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: mainColor.opacity(0.2), radius: 15, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [mainColor.opacity(0.5), accentColors[0].opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
    let asset: PHAsset
    let size: CGSize
    
    @State private var image: UIImage? = nil
    @StateObject private var photoManager = PhotoManager()
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                            .tint(Color(hex: "89CFF0"))
                    )
            }
        }
        .onAppear {
            photoManager.loadImage(for: asset, size: size) { loadedImage in
                if let loadedImage = loadedImage {
                    image = loadedImage
                }
            }
        }
    }
}

// MARK: - Helper Views
struct PhotoThumbnailView: View {
    let asset: PHAsset
    let height: CGFloat
    let cornerRadius: CGFloat
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .opportunistic
        option.resizeMode = .exact
        
        manager.requestImage(for: asset, 
                            targetSize: CGSize(width: 600, height: 600), 
                            contentMode: .aspectFill, 
                            options: option) { result, _ in
            if let image = result {
                self.image = image
            }
        }
    }
}

struct PhotoThumbnailCell: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var isSelected = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / 3 - 15, height: UIScreen.main.bounds.width / 3 - 15)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hue: Double.random(in: 0...1), 
                              saturation: 0.3, 
                              brightness: 0.9))
                    .frame(width: UIScreen.main.bounds.width / 3 - 15, height: UIScreen.main.bounds.width / 3 - 15)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.2)
                    )
            }
            
            // Selection circle
            Circle()
                .stroke(Color.white, lineWidth: 1.5)
                .background(Circle().fill(isSelected ? Color.pink : Color.clear))
                .frame(width: 22, height: 22)
                .padding(6)
                .onTapGesture {
                    isSelected.toggle()
                }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .opportunistic
        option.resizeMode = .exact
        
        manager.requestImage(for: asset, 
                            targetSize: CGSize(width: 300, height: 300), 
                            contentMode: .aspectFill, 
                            options: option) { result, _ in
            if let image = result {
                self.image = image
            }
        }
    }
}

// Custom button style for scaling effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - App Integration

struct PhotoGroupSelectionView: View {
    @Binding var selectedPhotos: [PHAsset]
    @Binding var showGroupSelection: Bool
    @Binding var hasSelectedPhotoGroup: Bool
    @State private var showPhotoGroups = true
    
    var body: some View {
        PhotoGroupsView(
            onGroupSelected: { groupPhotos in
                // When a group is selected, set the selected photos and close this view
                selectedPhotos = groupPhotos
                hasSelectedPhotoGroup = true
                showGroupSelection = false
            },
            onDismiss: {
                showGroupSelection = false
            }
        )
    }
}

// Environment wrapper to pass bindings through the view hierarchy
class EnvironmentWrapper: ObservableObject {
    @Binding var selectedPhotos: [PHAsset]
    @Binding var hasSelectedPhotoGroup: Bool
    
    init(selectedPhotos: Binding<[PHAsset]>, hasSelectedPhotoGroup: Binding<Bool>) {
        self._selectedPhotos = selectedPhotos
        self._hasSelectedPhotoGroup = hasSelectedPhotoGroup
    }
}

// Fix for the preview provider
#if DEBUG
struct PhotoGroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGroupSelectionView(
            selectedPhotos: .constant([]), 
            showGroupSelection: .constant(true),
            hasSelectedPhotoGroup: .constant(false)
        )
    }
}
#endif 