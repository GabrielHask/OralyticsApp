import SwiftUI

struct PhysiqueImprovementView: View {
    @State private var animate = false
    @State private var progress: Double = 0
    @State private var navigate = false

    var body: some View {
        NavigationView {
            VStack {
                // Main Content
                VStack(alignment: .leading, spacing: 30) {
                    
                    // Main Heading
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Our Program Will Help You")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Improve Your Teeth")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    // Graph with Enhancements
                    GraphView(animate: $animate)
                        .frame(height: 250)
                        .padding(.horizontal)
                        .onAppear {
                            withAnimation(.easeOut(duration: 2)) {
                                animate = true
                            }
                            withAnimation(.linear(duration: 3.5)) { // Updated duration here
                                progress = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                navigate = true
                            }
                        }
                }
                .padding()
                
                Spacer() // Pushes the following content to the bottom
                
                // Description Section
                VStack(alignment: .center, spacing: 10) {
                    Text("Through personalized routines and product recommendations, Oralytics will make you look and feel better")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center) // Center-align text
                    Text("*Based on Oralytics users data")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding([.horizontal, .bottom], 20)
                .offset(y: -20) // Move up slightly
                
                // Progress Bar
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                // Hidden NavigationLink
                NavigationLink(
                    destination: OnboardingView2().navigationBarBackButtonHidden(true),
                    isActive: $navigate,
                    label: {
                        EmptyView()
                    })
            }
            .background(
                Color.black
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct GraphView: View {
    @Binding var animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Background Gradient Fill
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addCurve(to: CGPoint(x: width, y: height * 0.6),
                                  control1: CGPoint(x: width * 0.3, y: height * 0.8),
                                  control2: CGPoint(x: width * 0.6, y: height * 0.65))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Background Line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addCurve(to: CGPoint(x: width, y: height * 0.6),
                                  control1: CGPoint(x: width * 0.3, y: height * 0.8),
                                  control2: CGPoint(x: width * 0.6, y: height * 0.65))
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(Color.gray.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .animation(.easeOut(duration: 2), value: animate)
                
                // Foreground Gradient Fill
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addCurve(to: CGPoint(x: width, y: height * 0.2),
                                  control1: CGPoint(x: width * 0.3, y: height * 0.4),
                                  control2: CGPoint(x: width * 0.6, y: height * 0.25))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Foreground Line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addCurve(to: CGPoint(x: width, y: height * 0.2),
                                  control1: CGPoint(x: width * 0.3, y: height * 0.4),
                                  control2: CGPoint(x: width * 0.6, y: height * 0.25))
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .animation(.easeOut(duration: 2).delay(0.5), value: animate)
                
                // Starting Point with Enlarged Label
                VStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                        .shadow(radius: 4)
                        .overlay(
                            Text("•")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                        )
                    Text("Dental \nAesthetics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(8)
                        .padding(.leading, 10)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .offset(x: 40, y: -15)
                }
                .position(x: 0, y: height)
                
                // Labels for Each Line
                VStack {
                    // Without SwoleAI Label
                    Text("Without Oralytics")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .position(x: width * 0.75, y: height * 0.6 + 23)
                    
                    // With SwoleAI Label
                    Text("With Oralytics")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .cornerRadius(8)
                        .position(x: width * 0.75, y: height * 0.01)
                }
            }
            .background(Color.black) // Ensures GraphView background is black
        }
    }
}

struct PhysiqueImprovementView_Previews: PreviewProvider {
    static var previews: some View {
        PhysiqueImprovementView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
