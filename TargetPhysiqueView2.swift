import SwiftUI
import UIKit

struct TargetPhysiqueView2: View {
    var onNext: (() -> Void)? // Closure for the Next button

    @State private var isTextVisible = false // State variable for text visibility
    @State private var navigateToOnboarding = false // State variable for navigation

    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        NavigationStack { // Use NavigationStack for modern navigation
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 25) { // Reduced spacing for better fit

                    // Top Text with Analysis Complete and Checkmark
                    VStack(spacing: 10) { // Reduced spacing
                        HStack(spacing: 6) {
                            Text("Analysis Complete")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        .opacity(isTextVisible ? 1 : 0)
                        .animation(.easeIn(duration: 0.6), value: isTextVisible)

                        Text("Congratulations! 76% of Oralytics users achieved your goals in 2 months.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25) // Adjusted padding
                            .opacity(isTextVisible ? 1 : 0)
                            .animation(.easeIn(duration: 0.6).delay(0.3), value: isTextVisible)
                    }
                    .padding(.top, 60) // Adjusted top padding

                    // Enhanced Bar Graph
                    VStack(spacing: 20) { // Adjusted spacing
                        HStack(spacing: 40) { // Reduced spacing between bars
                            BarView(label: "Your Score", percentage: 76, color: .green, isVisible: isTextVisible)
                            BarView(label: "Average", percentage: 35, color: .red, isVisible: isTextVisible)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30) // Adjusted horizontal padding
                    }

                    Spacer()

                    // Disclaimer Text
                    Text("*This result is an indication only through our analysis, not a guarantee.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)

                    // Next Button
                    Button(action: {
                        // Trigger the onNext closure if it exists
                        onNext?()
                        // Activate navigation to OnboardingView2
                        navigateToOnboarding = true
                        generateHapticFeedback()
                    }) {
                        Text("That's Amazing!")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12) // Smooth corner radius
                            .shadow(color: Color.orange.opacity(0.4), radius: 5, x: 0, y: 5)
                    }
                    .padding(.bottom, 35) // Adjusted bottom padding
                    .padding(.horizontal, 25)

                    // Hidden NavigationLink for programmatic navigation
                    NavigationLink(
                        destination: OnboardingView2().navigationBarBackButtonHidden(true),
                        isActive: $navigateToOnboarding,
                        label: {
                            EmptyView() // Empty view since we're navigating programmatically
                        })
                }
                .padding(.bottom, 20) // Additional bottom padding to prevent clipping
            }
            .onAppear {
                // Set text visibility to true after the view appears
                withAnimation {
                    isTextVisible = true
                }
            }
        }
    }
}

// Reusable BarView for the graph
struct BarView: View {
    let label: String
    let percentage: CGFloat
    let color: Color
    let isVisible: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 60, height: 200)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(10)

                Rectangle()
                    .frame(width: 60, height: isVisible ? 200 * percentage / 100 : 0)
                    .foregroundColor(color)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3), value: isVisible)

                Text("\(Int(percentage))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 220 * (percentage / 100))
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6).delay(0.3), value: isVisible) // Adds smooth fade-in for text
            }

            Text(label)
                .foregroundColor(.white)
                .font(.subheadline)
                .padding(.top, 8)
        }
    }
}

// Helper extension for corner radius customization
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TargetPhysiqueView2_Previews: PreviewProvider {
    static var previews: some View {
        TargetPhysiqueView2(onNext: {
            // Dummy closure for preview
            print("Next button tapped")
        })
    }
}
