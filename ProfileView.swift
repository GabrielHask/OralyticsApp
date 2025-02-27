import SwiftUI

struct ProfileView: View {
    @State private var showProfile = false
    @Environment(\.presentationMode) var presentationMode
    
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .shadow(radius: 3)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal)
                
                // Top Text
                VStack(spacing: 8) {
                    Text("Congratulations!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Based on your responses, Oralytics is a great fit for you. We've built your profile here.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Profile Card with Animation
                if showProfile {
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 280, height: 320)
                            .overlay(
                                VStack(spacing: 15) {
                                    Text("Oralytics")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.top, 10)
                                    
                                    Spacer()
                                    
                                    Text("Active Streak")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("0 days")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Oralytics since")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                        Text("11/03")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 15)
                                }
                            )
                            .shadow(radius: 5)
                            .padding(.top, 10)
                            .transition(.move(edge: .bottom)) // Defines the transition animation
                    }
                    .padding(.bottom, 20)
                }

                Spacer()

                // Next Button with NavigationLink
                NavigationLink(destination: EnableNotificationsView().navigationBarBackButtonHidden(true)) {
                    Text("Next")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 40)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) { // Specifies the animation type and duration
                    showProfile = true
                }
            }
            .navigationBarHidden(true) // Hides the navigation bar for a cleaner look
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
