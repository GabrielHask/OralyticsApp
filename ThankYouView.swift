import SwiftUI
import UIKit

struct ThankYouView: View {
    @State private var showConfetti = true
    @State private var navigateToSignInView = false
    @State private var isButtonEnabled = true
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        ZStack {
            VStack(spacing: 20) {

                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Go back to the previous screen
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                Text("Thank you for trusting us!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)

                Text("All of your information is secure and kept private!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)

                // Next button
                Button(action: {
                    generateHapticFeedback()
                    navigateToSignInView = true
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isButtonEnabled ? Color.black : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(!isButtonEnabled)
            }
            .padding()

            // Confetti animation


            // Navigation to SignInView
            NavigationLink(destination: SignInView().navigationBarBackButtonHidden(true), isActive: $navigateToSignInView) {
                EmptyView()
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    // Haptic feedback function
    private func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
}



// Dummy SignInView for demonstration purposes


struct ThankYouView_Previews: PreviewProvider {
    static var previews: some View {
        ThankYouView()
    }
}
