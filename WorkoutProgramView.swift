import SwiftUI

struct WorkoutProgramView: View {
    @Environment(\.presentationMode) var presentationMode
    var onContinue: (() -> Void)?
    
    @State private var progress = 0.0
    @State private var isFinished = false
    @State private var isTextVisible = false
    
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Improved Top Text with Enhanced Styling
                    VStack(spacing: 12) {
                        Text("AI Tailored Dental Products")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Find your best dental routine ✅")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(isTextVisible ? 1 : 0)
                            .animation(.easeIn(duration: 0.6), value: isTextVisible)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Workout Image with Enhanced Styling
                    Image("DentalProducts")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                    
                    Spacer()
                    
                    // New Text Above Progress Bar
                    Text("Comparing your responses with thousands of other Oralytics users")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(isTextVisible ? 1 : 0)
                        .animation(.easeIn(duration: 0.6).delay(0.2), value: isTextVisible) // Slight delay for staggered animation
                    
                    // Updated Green Progress Bar with Smooth Animation
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .onAppear {
                            startProgress()
                        }
                }
                .padding()
                
                // NavigationLink to QuestionView5
                NavigationLink(
                    destination: EnableNotificationsView().navigationBarBackButtonHidden(true),
                    isActive: $isFinished
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .onAppear {
                isTextVisible = true
            }
        }
    }
    
    private func startProgress() {
        let targetProgress = [0.0, 0.3, 0.6, 0.7, 1.0]
        let totalTime: Double = 5.0 // Total time to reach full progress
        let intervals = totalTime / Double(targetProgress.count)
        
        for (index, value) in targetProgress.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * intervals)) {
                withAnimation(.easeInOut(duration: intervals)) {
                    progress = value
                }
                if index == targetProgress.count - 1 {
                    generateHapticFeedback()
                    isFinished = true
                    onContinue?()
                }
            }
        }
    }
}

struct WorkoutProgramView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutProgramView(onContinue: {
            print("Continue button tapped")
        })
    }
}
