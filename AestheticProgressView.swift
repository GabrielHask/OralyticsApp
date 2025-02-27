import SwiftUI

struct AestheticProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for the typewriter effect
    @State private var attributedText: AttributedString = ""
    private let fullText: String = "Oralytics is the only platform to improve your teeth's aesthetic progress."
    private let typingSpeed: Double = 0.05 // Seconds per character
    
    // Define the range for "only platform"
    private let highlightRange: Range<String.Index>
    
    // State variables to manage navigation
    @State private var isTypingDone: Bool = false
    @State private var navigateToReferralCode: Bool = false
    
    // Initialize the highlight range
    init() {
        let start = "Oralytics is the ".endIndex
        let end = "Oralytics is the only platform".endIndex
        self.highlightRange = start..<end
    }
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ProgressView(value: 9.0, total: 15.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                    .frame(height: 4)
                    .padding(.horizontal)
                // Back Button
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        presentationMode.wrappedValue.dismiss() // Go back to the previous screen
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                // Centered content with VStack
                VStack(spacing: 20) {
                    // Typewriter Animated Text
                    VStack(spacing: 15) {
                        Text(attributedText)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .onAppear {
                                startTypewriterAnimation()
                            }
                        
                        // Additional Static Text
                        Text("Our users stay up to 2x more consistent!")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    
                    // NavigationLink for programmatic navigation
                    NavigationLink(
                        destination: ReferralCodeView().navigationBarBackButtonHidden(true),
                        isActive: $navigateToReferralCode,
                        label: {
                            EmptyView()
                        }
                    )
                    
                    // "Next" Button
                    Button(action: {
                        navigateToReferralCode = true
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTypingDone ? Color.black : Color.gray)
                            .cornerRadius(30)
                            .padding(.horizontal, 40)
                    }
                    .disabled(!isTypingDone) // Disable the button until typing is done
                    .opacity(isTypingDone ? 1.0 : 0.5) // Optional: Change opacity to indicate disabled state
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Centers the content
                
                // Bar graph at the bottom
                HStack(spacing: 60) {
                    VStack {
                        Text("Without Oralytics")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 100)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .frame(width: 40, height: 50)
                        }
                        
                        Text("1X")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    
                    VStack {
                        Text("With Oralytics")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 100)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .frame(width: 40, height: 100)
                        }
                        
                        Text("2X")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 5)
                    }
                }
                .padding(.bottom, 50) // Padding to bottom of screen
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // Ensures background is white and consistent
        }
    }
    
    // Function to start the typewriter animation
    private func startTypewriterAnimation() {
        attributedText = ""
        var currentIndex = fullText.startIndex
        isTypingDone = false
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < fullText.endIndex {
                let nextIndex = fullText.index(after: currentIndex)
                let range = currentIndex..<nextIndex
                var char = AttributedString(fullText[range])
                
                // Check if the current character is within the highlight range
                if range.lowerBound >= highlightRange.lowerBound && range.upperBound <= highlightRange.upperBound {
                    char.foregroundColor = .orange
                } else {
                    char.foregroundColor = .black
                }
                
                attributedText += char
                currentIndex = nextIndex
            } else {
                timer.invalidate()
                isTypingDone = true // Mark animation as complete
            }
        }
    }
}

struct AestheticProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AestheticProgressView()
    }
}


