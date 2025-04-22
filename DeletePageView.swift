import SwiftUI
import Photos

struct DeletePageView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var markedPhotos: [MarkedPhoto] = []
    @State private var selectedPhotos: Set<String> = []
    @State private var isSelectAll = false
    @State private var isLoading = true
    @State private var showConfirmation = false
    @State private var showRestoreConfirmation = false
    @State private var photoToRestore: MarkedPhoto? = nil
    
    // Add a reference to the deletedPhotoStore
    @ObservedObject var deletedPhotoStore: DeletedPhotoStore
    
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
                        Text("Deleted Photos")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "5E5CE6"))
                        
                        Spacer()
                        
                        // Delete selected button
                        Button(action: {
                            if !selectedPhotos.isEmpty {
                                showConfirmation = true
                            }
                        }) {
                            Text("Delete")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedPhotos.isEmpty ? Color.gray : accentColor1)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedPhotos.isEmpty ? Color.gray.opacity(0.1) : accentColor1.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedPhotos.isEmpty ? Color.gray.opacity(0.2) : accentColor1.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                        .disabled(selectedPhotos.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Selection controls
                    HStack {
                        // Select all toggle
                        Button(action: {
                            isSelectAll.toggle()
                            if isSelectAll {
                                selectedPhotos = Set(markedPhotos.map { $0.id })
                            } else {
                                selectedPhotos.removeAll()
                            }
                        }) {
                            HStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(mainColor, lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    
                                    if isSelectAll {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(mainColor)
                                            .frame(width: 14, height: 14)
                                    }
                                }
                                
                                Text("Select All")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(mainColor)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(mainColor.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                        
                        // Counter
                        Text("\(selectedPhotos.count) selected")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.6))
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .background(
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(mainColor)
                    Text("Loading deleted photos...")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .padding(.top, 16)
                    Spacer()
                } else if markedPhotos.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "trash.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor.opacity(0.7))
                        
                        Text("No Deleted Photos")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "5E5CE6"))
                        
                        Text("Photos you mark for deletion will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    // Grid of deleted photos
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(markedPhotos) { photo in
                                DeletedPhotoCell(
                                    photo: photo,
                                    isSelected: selectedPhotos.contains(photo.id),
                                    mainColor: mainColor,
                                    accentColor: accentColor1,
                                    onSelect: { isSelected in
                                        if isSelected {
                                            selectedPhotos.insert(photo.id)
                                        } else {
                                            selectedPhotos.remove(photo.id)
                                        }
                                        isSelectAll = selectedPhotos.count == markedPhotos.count
                                    },
                                    onRestore: {
                                        photoToRestore = photo
                                        showRestoreConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
            
            // Delete confirmation dialog
            if showConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(accentColor1)
                            
                            Text("Permanently Delete?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "5E5CE6"))
                            
                            Text("This will permanently delete \(selectedPhotos.count) photo\(selectedPhotos.count > 1 ? "s" : "") from your device.")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                showConfirmation = false
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
                                // Permanently delete selected photos
                                deleteSelectedPhotos()
                                showConfirmation = false
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
                                                    gradient: Gradient(colors: [accentColor1, Color(hex: "FF5F6D")]),
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
            
            // Restore confirmation dialog
            if showRestoreConfirmation, let photo = photoToRestore {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(accentColor2)
                            
                            Text("Restore Photo?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "5E5CE6"))
                            
                            Text("This photo will be restored to your camera roll.")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Photo preview
                        Image(uiImage: photo.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                showRestoreConfirmation = false
                                photoToRestore = nil
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
                                // Restore photo
                                restorePhoto(photo)
                                showRestoreConfirmation = false
                                photoToRestore = nil
                            }) {
                                Text("Restore")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [accentColor2, mainColor]),
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
        .onAppear {
            loadMarkedPhotos()
        }
    }
    
    // Load photos marked for deletion
    func loadMarkedPhotos() {
        isLoading = true
        
        // Short delay to show loading animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Use actual deleted photos from the store
            self.markedPhotos = self.deletedPhotoStore.deletedPhotos
            self.isLoading = false
        }
    }
    
    // Delete selected photos permanently
    func deleteSelectedPhotos() {
        // First check if we have the PHAsset identifiers for the selected photos
        // We need to add a property to MarkedPhoto to store the PHAsset localIdentifier
        let selectedMarkedPhotos = markedPhotos.filter { photo in
            selectedPhotos.contains(photo.id)
        }
        
        // If we have PHAssets to delete from the device
        if let photoAssets = getPhotoAssetsToDelete(for: selectedMarkedPhotos) {
            // Request permission to delete from photo library
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(photoAssets as NSArray)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        // Successfully deleted from device, now remove from our store
                        for photoId in self.selectedPhotos {
                            self.deletedPhotoStore.removePhoto(withId: photoId)
                        }
                        
                        self.markedPhotos.removeAll { photo in
                            self.selectedPhotos.contains(photo.id)
                        }
                        self.selectedPhotos.removeAll()
                        self.isSelectAll = false
                    } else {
                        print("Error deleting photos: \(error?.localizedDescription ?? "Unknown error")")
                        // Handle the error (could show an alert to the user)
                    }
                }
            }
        } else {
            // If we don't have PHAssets (older code path), just remove from our store
            for photoId in selectedPhotos {
                deletedPhotoStore.removePhoto(withId: photoId)
            }
            
            markedPhotos.removeAll { photo in
                selectedPhotos.contains(photo.id)
            }
            selectedPhotos.removeAll()
            isSelectAll = false
        }
    }
    
    // Helper function to get PHAssets for photos we want to delete
    private func getPhotoAssetsToDelete(for photos: [MarkedPhoto]) -> [PHAsset]? {
        var assets: [PHAsset] = []
        
        for photo in photos {
            if let localIdentifier = photo.assetLocalIdentifier {
                // If we have the PHAsset localIdentifier, use it for exact matching
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                if let asset = fetchResult.firstObject {
                    assets.append(asset)
                }
            } else {
                // Fallback to date-based search if no identifier (less reliable)
                let fetchOptions = PHFetchOptions()
                let creationDate = photo.date
                fetchOptions.predicate = NSPredicate(format: "creationDate = %@", creationDate as NSDate)
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                
                if let asset = fetchResult.firstObject {
                    assets.append(asset)
                }
            }
        }
        
        return assets.isEmpty ? nil : assets
    }
    
    // Restore a photo to camera roll
    func restorePhoto(_ photo: MarkedPhoto) {
        // Remove from the shared store
        deletedPhotoStore.removePhoto(withId: photo.id)
        
        if let index = markedPhotos.firstIndex(where: { $0.id == photo.id }) {
            markedPhotos.remove(at: index)
        }
        
        if selectedPhotos.contains(photo.id) {
            selectedPhotos.remove(photo.id)
        }
        
        isSelectAll = selectedPhotos.count == markedPhotos.count && !markedPhotos.isEmpty
    }
}

// MARK: - Deleted Photo Cell

struct DeletedPhotoCell: View {
    let photo: MarkedPhoto
    let isSelected: Bool
    let mainColor: Color
    let accentColor: Color
    let onSelect: (Bool) -> Void
    let onRestore: () -> Void
    
    @State private var showOptions = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Photo with fixed aspect ratio and dimensions
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 200)
                .clipped()
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? 
                                LinearGradient(
                                    gradient: Gradient(colors: [mainColor, accentColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            
            // Selection checkbox
            Button(action: {
                onSelect(!isSelected)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [mainColor, accentColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding(8)
            
            // Date and restore button
            VStack {
                Spacer()
                
                HStack {
                    // Date
                    Text(formattedDate(photo.date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Restore button
                    Button(action: {
                        onRestore()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [mainColor.opacity(0.8), mainColor.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(8)
                    }
                }
                .padding(8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(!isSelected)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct DeletePageView_Previews: PreviewProvider {
    static var previews: some View {
        DeletePageView(deletedPhotoStore: DeletedPhotoStore())
    }
} 