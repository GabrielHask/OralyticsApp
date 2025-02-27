import SwiftUI
import StoreKit

struct AppRatingsView: View {
    // Use @State instead of @AppStorage to avoid persisting the state across app launches
    @State private var hasRated = false
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer(minLength: 10) // Reduced space between navigation and main content
                
                // Main Content
                VStack(spacing: 15) { // Reduced spacing from 20 to 15
                    // Title and Subtitle
                    VStack(spacing: 5) { // Reduced spacing from 10 to 5
                        Text("Give Us A Rating")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Oralytics was Made to Help You Improve!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.black)
                            .padding(.horizontal)
                    }
                    
                    // Rating Image
                    Image("5star") // Ensure this image exists in your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.vertical, 5) // Reduced vertical padding
                    
                    // Testimonials
                    VStack(alignment: .center, spacing: 20) {
                        // Marcus Swartz's Testimonial
                        testimonialView(
                            text: "“Love Oralytics! Just snap a pic, get my score, and receive personalized dental tips instantly”",
                            author: "- RyanS33"
                        )
                        
                        // Andrej Chen's Testimonial
                        testimonialView(
                            text: "“Started with a 64 rating but got it up to a 80 in a matter of weeks. Feeling a lot more comfortable and confident!",
                            author: "- HJackson2"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 10) // Reduced space between main content and button
                
                // "I rated!" Button - Visible only after rating
                if hasRated {
                    Button(action: {
                        navigateToNextView = true
                    }) {
                        Text("I rated!")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // "Leave a rating!" Button - Visible only if not rated yet
                if !hasRated {
                    Button(action: {
                        generateHapticFeedback()
                        requestReview()
                        hasRated = true // Update state to show "I rated!" button
                    }) {
                        Text("Leave a rating!")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(false) // Enable the button (adjust as needed)
                }
                
                Spacer() // Maintains spacing below the button
                
                // Navigation Link
                NavigationLink(destination: SignInView().navigationBarHidden(true), isActive: $navigateToNextView) {
                    EmptyView()
                }
                .navigationViewStyle(.stack)

            }
            .background(Color.white)
            // .padding(.bottom)
            // Reset hasRated to false every time the view appears
            .onAppear {
                hasRated = false
            }
        }
    }

    // Reusable Testimonial View
    private func testimonialView(text: String, author: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
                .font(.body)
                .italic()
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding()

            HStack {
                Spacer()
                Text(author)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 10)
        }
        .background(Color(red: 242/255, green: 242/255, blue: 247/255))
        .cornerRadius(10)
        .frame(minHeight: 150)
    }

    // Haptic Feedback Generator
    private func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    // Review Request Function
    private func requestReview() {
        if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview()
        } else {
            print("Review request not available for this iOS version.")
        }
    }
}

struct AppRatingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Embed in NavigationView for NavigationLink
            AppRatingsView()
        }
    }
}
