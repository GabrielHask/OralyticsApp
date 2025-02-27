//
//  StartPageView.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI

struct TypingTextView: View {
    @State private var animatedText = ""
    

    private let fullText: String
    private let delay: Double
    var onComplete: (() -> Void)? // Callback for when animation completes


    // Task for managing the typing animation
    @State private var typingTask: Task<Void, Never>? = nil
    
    // Cursor blinking state
    @State private var showCursor = true
    
    init(text: String, delay: Double = 0.15, onComplete: (() -> Void)? = nil) {
        self.fullText = text
        self.delay = delay
        self.onComplete = onComplete
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(animatedText)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
            
            // Blinking cursor
            if !isTypingComplete {
                Text("|")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
                    .opacity(showCursor ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showCursor)
            }
        }
        .onAppear {
            startTypingAnimation()
            startCursorBlinking()
        }
        .onDisappear {
            // Cancel the typing task if the view disappears
            typingTask?.cancel()
        }
    }
    
    @State private var isTypingComplete = false
    
    private func startTypingAnimation() {
        typingTask = Task {
            for character in fullText {
                // Check if the task has been canceled
                if Task.isCancelled {
                    break
                }
                await Task.sleep(UInt64(delay * 1_000_000_000)) // Convert delay to nanoseconds
                animatedText.append(character)
            }
            isTypingComplete = true
            onComplete?()
        }
    }
    
    private func startCursorBlinking() {
        // Toggle the cursor visibility to create a blinking effect
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation {
                showCursor.toggle()
            }
        }
    }
}

struct StartPageView: View {
    @State private var isAnimationComplete = false // Track animation completion

    @State private var logoScale: CGFloat = 1.0
    
    // Method to generate haptic feedback
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        VStack {
            // Navigation back button (hidden space for layout)
            HStack {
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Logo image
            
            ZStack {
                Image("AppLogo")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            // Main label with typing animation
            VStack {
                Text("Oralytics")
                    .font(.system(size: 46, weight: .bold)) // Larger, bolder font for emphasis
                    .foregroundColor(.white) // Use primary color for better contrast
                    .shadow(color: .white, radius: 2)
                    .padding(.bottom, 4)
                
                // Typing animation for "Scan. Rate. Grow."
                TypingTextView(text: "Scan. Rate. Shine.", delay: 0.20) { // Increased delay here
                    isAnimationComplete = true // Set flag to true when animation completes
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 60)
            
            //             Conditionally show the "Get Started" button
            if isAnimationComplete {
                NavigationLink(destination: PhysiqueScan2View().navigationBarBackButtonHidden(true)) {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold)) // Larger font for better visibility
                        .cornerRadius(12) // Slightly larger corner radius for a softer look
                        .shadow(color: .black, radius: 3) // Add shadow for a modern effect
                }
                .navigationViewStyle(.stack)
                .simultaneousGesture(TapGesture().onEnded {
                    generateHapticFeedback()
                })
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .padding()
        //        .background(Color(UIColor.systemBackground)) // Background color for better contrast
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color(red:35/255, green: 39/255, blue: 51/255))
        .font(.system(size: 16))
    }
}




#Preview{
    StartPageView()
}



