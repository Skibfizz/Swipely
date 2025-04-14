//
//  OnboardingView.swift
//  Swipely
//
//  Created by paris on 13/04/2025.
//

import SwiftUI
import Photos

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateBackground = false
    @State private var animateContent = false
    
    // More fun and vibrant gradients
    private let gradients: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.8, blue: 1.0), Color.white]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.9), Color.white]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.5, green: 0.8, blue: 1.0), Color.white]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.7, blue: 1.0), Color.white]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.85, blue: 0.95), Color.white]), startPoint: .top, endPoint: .bottom)
    ]
    
    // More fun accent colors
    private let accentColors: [Color] = [
        Color(red: 0.0, green: 0.65, blue: 1.0),
        Color(red: 0.2, green: 0.7, blue: 0.9),
        Color(red: 0.1, green: 0.75, blue: 0.95),
        Color(red: 0.0, green: 0.7, blue: 1.0),
        Color(red: 0.1, green: 0.8, blue: 1.0)
    ]
    
    // Fun emojis for each page
    private let emojis = ["📱", "👆", "♻️", "🔐", "🎉"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fun background with more visible elements
                ZStack {
                    // Base gradient
                    gradients[min(currentPage, gradients.count - 1)]
                        .ignoresSafeArea()
                    
                    // More playful background shapes
                    Circle()
                        .fill(accentColors[min(currentPage, accentColors.count - 1)].opacity(0.1))
                        .frame(width: geometry.size.width * 0.8)
                        .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.1)
                        .blur(radius: 20)
                    
                    Circle()
                        .fill(accentColors[min(currentPage, accentColors.count - 1)].opacity(0.12))
                        .frame(width: geometry.size.width * 0.6)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.85)
                        .blur(radius: 25)
                        
                    // Floating bubbles
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(accentColors[min(currentPage, accentColors.count - 1)].opacity(0.1))
                            .frame(width: CGFloat([25, 40, 30, 20, 35][index % 5]))
                            .position(
                                x: CGFloat([80, geometry.size.width - 70, geometry.size.width - 100, 60, geometry.size.width/2][index % 5]),
                                y: CGFloat([100, geometry.size.height - 100, 150, geometry.size.height - 150, geometry.size.height/2 - 200][index % 5])
                            )
                            .offset(y: animateBackground ? [-15, 15, -10, 10, -8][index % 5] : [5, -5, 10, -10, 3][index % 5])
                            .animation(
                                Animation.easeInOut(duration: [5, 7, 6, 4, 5][index % 5])
                                    .repeatForever(autoreverses: true),
                                value: animateBackground
                            )
                    }
                }
                
                // Main content
                VStack(spacing: 0) {
                    // Fun header
                    HStack {
                        Text("Swipely")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(accentColors[min(currentPage, accentColors.count - 1)])
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                            .opacity(0.9)
                        
                        Spacer()
                        
                        // Emoji indicator
                        Text(emojis[min(currentPage, emojis.count - 1)])
                            .font(.system(size: 28))
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                            .opacity(0.9)
                    }
                    
                    // Page content with improved TabView
                    TabView(selection: $currentPage) {
                        // Page 1: Welcome
                        OnboardingPageView(
                            image: "photo.stack",
                            secondaryImage: "square.stack.fill",
                            emoji: "📱",
                            title: "Welcome to Swipely!",
                            description: "The fun way to organize your photos and free up space. No more endless scrolling!",
                            pageNumber: 0,
                            accentColor: accentColors[0]
                        )
                        .tag(0)
                        .transition(.opacity)
                        
                        // Page 2: Swipe Mechanics
                        OnboardingPageView(
                            image: "hand.draw",
                            secondaryImage: "arrow.left.and.right",
                            emoji: "👆",
                            title: "Swipe Away!",
                            description: "Swipe right to keep the good ones. Swipe left to send the not-so-great ones to the bin.",
                            pageNumber: 1,
                            accentColor: accentColors[1]
                        )
                        .tag(1)
                        .transition(.opacity)
                        
                        // Page 3: Recovery
                        OnboardingPageView(
                            image: "arrow.uturn.backward.circle",
                            secondaryImage: "arrow.clockwise",
                            emoji: "♻️",
                            title: "Changed Your Mind?",
                            description: "No worries! Anything in the recycle bin can be brought back with a quick tap.",
                            pageNumber: 2,
                            accentColor: accentColors[2]
                        )
                        .tag(2)
                        .transition(.opacity)
                        
                        // Page 4: Photo Permission Information
                        OnboardingPageView(
                            image: "photo.badge.plus",
                            secondaryImage: "lock.open",
                            emoji: "🔐",
                            title: "Just One Thing...",
                            description: "We'll need to peek at your photos. When your phone asks, just tap \"Allow Access\"!",
                            pageNumber: 3,
                            isPermissionPage: true,
                            accentColor: accentColors[3]
                        )
                        .tag(3)
                        .transition(.opacity)
                        
                        // Page 5: Get Started
                        OnboardingPageView(
                            image: "checkmark.circle",
                            secondaryImage: "sparkles",
                            emoji: "🎉",
                            title: "You're All Set!",
                            description: "Time to clean up those photos! Let's get swiping!",
                            pageNumber: 4,
                            accentColor: accentColors[4]
                        )
                        .tag(4)
                        .transition(.opacity)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                    .frame(height: geometry.size.height * 0.75)
                    
                    // Fun navigation controls
                    VStack(spacing: 28) {
                        // Playful progress bar
                        ZStack(alignment: .leading) {
                            // Background track
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            // Foreground progress
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            accentColors[min(currentPage, accentColors.count - 1)],
                                            accentColors[min(currentPage, accentColors.count - 1)].opacity(0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.8 * CGFloat(currentPage + 1) / 5, height: 6)
                                .animation(.easeInOut, value: currentPage)
                        }
                        .frame(width: geometry.size.width * 0.8)
                        
                        // Navigation buttons - more playful
                        HStack {
                            // Back button - more casual
                            Button(action: {
                                withAnimation {
                                    if currentPage > 0 {
                                        currentPage -= 1
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Back")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(currentPage > 0 ? accentColors[min(currentPage, accentColors.count - 1)] : .clear)
                                .padding(.horizontal, 12)
                                .frame(height: 40)
                            }
                            .opacity(currentPage > 0 ? 1 : 0)
                            .disabled(currentPage == 0)
                            
                            Spacer()
                            
                            // Continue/Get Started button - more fun
                            Button(action: {
                                if currentPage < 4 {
                                    // For permissions page, request photo access
                                    if currentPage == 3 {
                                        requestPhotoAccess()
                                    }
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    // On last page, complete onboarding with animation
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        hasCompletedOnboarding = true
                                    }
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Text(currentPage < 4 ? "Next" : "Let's Go!")
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    if currentPage == 4 {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .frame(height: 52)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 26)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        accentColors[min(currentPage, accentColors.count - 1)],
                                                        accentColors[min(currentPage, accentColors.count - 1)].opacity(0.8)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        // Subtle pattern
                                        if currentPage == 4 {
                                            HStack(spacing: 4) {
                                                ForEach(0..<8) { _ in
                                                    Circle()
                                                        .fill(Color.white.opacity(0.15))
                                                        .frame(width: 4, height: 4)
                                                }
                                            }
                                        }
                                    }
                                )
                                .shadow(color: accentColors[min(currentPage, accentColors.count - 1)].opacity(0.4), radius: 15, x: 0, y: 8)
                                .scaleEffect(currentPage == 4 ? 1.05 : 1.0)
                                .animation(.easeInOut, value: currentPage)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                // Start animations
                animateBackground = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        animateContent = true
                    }
                }
            }
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            // We'll still proceed regardless of the status
            // The status will be handled in ContentView
        }
    }
}

struct OnboardingPageView: View {
    let image: String
    var secondaryImage: String = ""
    var emoji: String = ""
    let title: String
    let description: String
    let pageNumber: Int
    var isPermissionPage: Bool = false
    var accentColor: Color = .blue
    
    @State private var animateContent = false
    @State private var showFirstIcon = true
    @State private var isIconAnimating = false
    @State private var emojiBounce = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Spacer(minLength: 20)
                
                // Fun icon with emoji
                ZStack {
                    // Background circles
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .fill(accentColor.opacity(0.08))
                        .frame(width: 220, height: 220)
                    
                    // Main icon with animated switching
                    ZStack {
                        // Primary icon
                        Image(systemName: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                            .foregroundColor(accentColor)
                            .opacity(showFirstIcon ? 1 : 0)
                            .scaleEffect(showFirstIcon ? 1 : 0.8)
                        
                        // Secondary icon (only when provided)
                        if !secondaryImage.isEmpty {
                            Image(systemName: secondaryImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .foregroundColor(accentColor)
                                .opacity(showFirstIcon ? 0 : 1)
                                .scaleEffect(showFirstIcon ? 0.8 : 1)
                        }
                    }
                    .scaleEffect(isIconAnimating ? 1.05 : 1.0)
                    
                    // Emoji badge
                    if !emoji.isEmpty {
                        Text(emoji)
                            .font(.system(size: 36))
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .offset(x: 60, y: -60)
                            .scaleEffect(emojiBounce ? 1.1 : 1.0)
                            .rotationEffect(.degrees(emojiBounce ? 10 : 0))
                            .animation(
                                Animation.spring(response: 0.5, dampingFraction: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(1.5),
                                value: emojiBounce
                            )
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    emojiBounce = true
                                }
                            }
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .onAppear {
                    // Create subtle pulsing animation for icons
                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isIconAnimating = true
                    }
                    
                    // Only animate between icons if there's a secondary icon
                    if !secondaryImage.isEmpty {
                        // Setup timer to switch between icons every 3 seconds
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 0.6)) {
                                showFirstIcon.toggle()
                            }
                        }
                    }
                }
                
                // Fun title
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(.darkText))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)
                
                // Casual description
                Text(description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(.darkGray))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 35)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)
                
                // Fun permission UI
                if isPermissionPage {
                    VStack(spacing: 25) {
                        // More playful permission prompt
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                                .frame(width: 260, height: 110)
                            
                            VStack(spacing: 12) {
                                Text("\"Swipely\" Would Like to Access Your Photos")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.darkText))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                
                                HStack(spacing: 10) {
                                    // Don't Allow Button
                                    Text("Don't Allow")
                                        .font(.system(size: 13))
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(14)
                                    
                                    // Allow Button - highlighted with bounce
                                    Text("Allow")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 18)
                                        .background(accentColor)
                                        .cornerRadius(14)
                                        .scaleEffect(isIconAnimating ? 1.05 : 1.0)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: true)
                                                .delay(1.0),
                                            value: isIconAnimating
                                        )
                                }
                                .padding(.bottom, 12)
                            }
                        }
                        .scaleEffect(0.95)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Casual permission instructions
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .top, spacing: 16) {
                                // Friendly checkmark
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.15))
                                        .frame(width: 38, height: 38)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 24))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tap \"Allow\"")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color(.darkText))
                                    
                                    Text("We need this to help organize your photos! 📸")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(.darkGray))
                                        .lineLimit(2)
                                }
                            }
                            
                            HStack(alignment: .top, spacing: 16) {
                                // Friendly X mark
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.15))
                                        .frame(width: 38, height: 38)
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 24))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Skip \"Don't Allow\"")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color(.darkText))
                                    
                                    Text("The app won't work without photos access! 🙈")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(.darkGray))
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding(25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .frame(width: geometry.size.width - 50)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width)
            .onAppear {
                // Sequential animations for better visual flow
                withAnimation(Animation.easeOut(duration: 0.5)) {
                    animateContent = true
                }
            }
            .onDisappear {
                // Reset animations when view disappears
                animateContent = false
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 