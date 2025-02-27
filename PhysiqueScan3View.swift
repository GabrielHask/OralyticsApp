import SwiftUI

struct PhysiqueScan3View: View {
    // Change the count from 5 to 4 to have four progress bars
    @State private var progress: [CGFloat] = Array(repeating: 0.0, count: 4) // Initial progress values for bars
    
    // Define target heights for each bar with each subsequent bar 1.5 times the previous
    private let targetHeights: [CGFloat] = {
        let baseHeight: CGFloat = 50
        let multiplier: CGFloat = 1.5
        return (0..<4).map { index in // Change the range from 0..<5 to 0..<4
            baseHeight * pow(multiplier, CGFloat(index))
        }
    }()
    
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Proportionate Top Section with Progress Bars
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: UIScreen.main.bounds.height * 0.5) // Adjust the height proportionately
                
                // Animated Progress Bars
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<progress.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 20, height: progress[index]) // Varying heights for each bar
                            .animation(
                                .easeInOut(duration: 1.5)
                                    .delay(Double(index) * 0.3),
                                value: progress[index]
                            ) // Animation with staggered delay
                    }
                }
                .padding(.horizontal, 32)
            }
            
            // Text Section
            VStack(spacing: 16) {
                Text("Improve your teeth")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Follow our AI-tailored advice and recommended products to improve your dental health and appearance. Ultimately save on extra dental checkups and problems due to bad teeth.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)
            
            Spacer()
            
            // Next Button
            NavigationLink(destination: OnboardingView1().navigationBarBackButtonHidden(true)) {
                Text("Get Started!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            .simultaneousGesture(TapGesture().onEnded {
                generateHapticFeedback()
            })
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            animateBars()
        }
    }
    /// Animates the progress bars by setting their target heights with staggered delays.
    private func animateBars() {
        for index in progress.indices {
            let delay = Double(index) * 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    progress[index] = targetHeights[index]
                }
            }
        }
    }
}

struct PhysiqueScan3View_Previews: PreviewProvider {
    static var previews: some View {
        PhysiqueScan3View()
    }
}
