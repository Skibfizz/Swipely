import SwiftUI
import Photos

struct WelcomeView: View {
    // State variable to track authorization status
    @State private var photoLibraryAuthorizationStatus: PHAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled") // Placeholder icon
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 30)

            Text("Welcome to Swipely!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Quickly manage your photos by swiping.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Swipe left to delete, swipe right to keep.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Show button only if permission hasn't been granted or denied yet
            if photoLibraryAuthorizationStatus == .notDetermined {
                Button("Get Started") {
                    requestPhotoLibraryAccess()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            } else if photoLibraryAuthorizationStatus == .authorized {
                 // If authorized, perhaps navigate away or show the main interface
                 // For now, just display a message
                 Text("Access Granted!")
                     .foregroundColor(.green)
            } else {
                // If denied, show guidance on how to enable in Settings
                 Text("Please grant photo library access in Settings to use Swipely.")
                     .font(.caption)
                     .foregroundColor(.red)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal)
                     // You might want to add a button to open the Settings app here
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // Check current authorization status when the view appears
            photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    // Function to request photo library access
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            // Update the state on the main thread after the user responds
            DispatchQueue.main.async {
                self.photoLibraryAuthorizationStatus = status
                // Handle the different authorization statuses here
                // For example, navigate to the main swiping view if authorized.
            }
        }
    }
}

// Preview provider for SwiftUI Canvas
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
