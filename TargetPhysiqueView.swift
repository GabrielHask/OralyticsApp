import SwiftUI

struct TargetPhysiqueView: View {
    @Environment(\.presentationMode) var presentationMode
    var onContinue: (() -> Void)?
    
    @State private var progress = 0.0
    @State private var isFinished = false
    @State private var showText1 = false
    @State private var showText2 = false
    @State private var showText3 = false

    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    // Top Text with highlighted percentage and sequential animations
                    VStack(alignment: .center, spacing: 8) {
                        Text("Oralytics users saw a ")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(showText1 ? 1 : 0)
                            .multilineTextAlignment(.center) // Center text
                            .animation(.easeIn(duration: 0.5), value: showText1)

                        Text("60%")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.orange)
                            .opacity(showText2 ? 1 : 0)
                            .multilineTextAlignment(.center) // Center text
                            .animation(.easeIn(duration: 0.5).delay(0.5), value: showText2)

                        Text(" increase in their overall dental rating after 2 months of using the app.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(showText3 ? 1 : 0)
                            .multilineTextAlignment(.center) // Center text
                            .animation(.easeIn(duration: 0.5).delay(1), value: showText3)
                    }
                    .frame(maxWidth: .infinity) // Allow VStack to take full width
                    .padding(.top, 40)

                    Spacer()

                    
                    // SwoleChart Image witsh improved styling
                    
                    Image("NEWCHART")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.7), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)

                    Spacer()

                    // Progress Bar
                    ProgressBar(value: $progress)
                        .frame(height: 20)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(.orange)
                        .animation(.easeInOut(duration: 7), value: progress)
                        .onAppear {
                            startProgress()
                            
                        }
                }
                
                
                
                .padding()
                .onAppear {
                    animateTexts()
                }
            }
            .navigationDestination(isPresented: $isFinished) {
                TargetPhysiqueView2(onNext: {
                    // Navigate to the next view, e.g., GenderSelectionView
                })
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func animateTexts() {
        // Sequentially show each text with delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                showText1 = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showText2 = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation {
                showText3 = true
            }
        }
    }

    private func startProgress() {
        let targetProgress = [0.0, 0.3, 0.6, 0.9, 1.0]
        let totalTime: Double = 7.0
        let intervals = totalTime / Double(targetProgress.count)

        for (index, value) in targetProgress.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * intervals)) {
                withAnimation {
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

struct ProgressBar: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(10)
                    .foregroundColor(Color.gray.opacity(0.3))

                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .cornerRadius(10)
                    .foregroundColor(Color.orange)
                    .animation(.linear, value: value)
            }
        }
    }
}

