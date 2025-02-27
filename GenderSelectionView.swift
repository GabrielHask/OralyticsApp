import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender? = nil
    @State private var isNextActive = false

    enum Gender: String {
        case male = "male"
        case female = "female"
    }

    @Environment(\.presentationMode) var presentationMode

    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        VStack {
            // Progress bar
            ProgressView(value: 1.0, total: 15.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .black))
                .frame(height: 4)
                .padding(.horizontal)

            // Navigation back button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                Spacer()
            }
            .padding()

            // Title
            Text("Are you male or female?")
                .font(.system(size: 36, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)

            Spacer() // Add space between title and buttons

            // Gender Selection Buttons
            VStack(spacing: 16) {
                genderButton(title: "Male", gender: .male)
                genderButton(title: "Female", gender: .female)
            }
            .padding(.horizontal)

            Spacer() // Add space between buttons and "Next" button

            // Next Button
            NavigationLink(destination: AestheticProgressView().navigationBarBackButtonHidden(true), isActive: $isNextActive) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGender != nil ? Color.black : Color.gray)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
                    .cornerRadius(10)
            }
            .navigationViewStyle(.stack)
            .simultaneousGesture(TapGesture().onEnded {
                generateHapticFeedback()
                saveGenderToUserDefaults() // Save the gender when "Next" is tapped
            })
            .padding()
            .disabled(selectedGender == nil)

            Spacer() // Add final spacer to keep content centered
        }
        .padding()
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }

    // Custom button for gender selection
    private func genderButton(title: String, gender: Gender) -> some View {
        Button(action: {
            selectedGender = gender
            saveGenderToUserDefaults() // Save the gender when selected
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedGender == gender ? Color.black : Color.white)
                .foregroundColor(selectedGender == gender ? .white : .black)
                .font(.system(size: 20, weight: .medium))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }

    // Function to save the gender in UserDefaults
    func saveGenderToUserDefaults() {
        if let selectedGender = selectedGender {
            UserDefaults.standard.set(selectedGender.rawValue, forKey: "selectedGender")
        }
    }
}

struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSelectionView()
    }
}
