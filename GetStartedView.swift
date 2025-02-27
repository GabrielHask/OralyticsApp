import SwiftUI

struct GetStartedView: View {
    @State private var showLogo = false
    @State private var showScan = false
    @State private var showRate = false
    @State private var showGrow = false
    @State private var showGetStarted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo
                if showLogo {
                    Image("AppLogo") // Replace with your logo image name
                        .resizable()
                        .foregroundColor(Color.black)
                        .scaledToFit()
                        .frame(height: 100) // Adjust size as needed
                        .onAppear {
                            triggerHapticFeedback()
                        }
                }
                
                // Scan
                if showScan {
                    Text("Scan.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .onAppear {
                            triggerHapticFeedback()
                        }
                }
                
                // Rate
                
                
                if showRate {
                    Text("Analyze.")
                        .font(.title)
                        .onAppear {
                            triggerHapticFeedback()
                        }
                }
                
                // Grow
                
                if showGrow {
                    Text("Shine.")
                        .font(.title)
                        .onAppear {
                            triggerHapticFeedback()
                        }
                }
                
                // Get Started Button
                
                if showGetStarted {
                    NavigationLink(destination: UploadPictureView(reset: .constant(false)).navigationBarHidden(true)) {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .onAppear {
                animateSequence()
            }
            .navigationTitle("Get Started")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func animateSequence() {
        // Display each element with delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showLogo = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showScan = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showRate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            showGrow = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            showGetStarted = true
        }
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
