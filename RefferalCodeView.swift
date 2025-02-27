import SwiftUI
import FirebaseFirestore

struct ReferralCodeView: View {
    @State private var referralCode: String = ""
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode

    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                Text("Do you have a referral code?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .padding(.bottom, 20)

                TextField("Enter referral code", text: $referralCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.default)

                Text("Enter a referral code or skip")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                Button(action: {
                    generateHapticFeedback()
                    // Log referral code usage and navigate
                    if !referralCode.isEmpty {
                        logReferralCodeUsage(referralCode: referralCode)
                    }
                    navigateToNextView = true
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Referral Code")
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToNextView) {
                SignInView().navigationBarHidden(true)
            }
        }
    }

    private func logReferralCodeUsage(referralCode: String) {
        let db = Firestore.firestore()
        let ref = db.collection("ReferralCodes").document(referralCode)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            
            do {
                document = try transaction.getDocument(ref)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            let currentCount = document.data()?["UsageCount"] as? Int ?? 0
            transaction.updateData(["UsageCount": currentCount + 1], forDocument: ref)

            return nil
        }) { (result, error) in
            if let error = error {
                print("Error logging referral code usage: \(error)")
            } else {
                print("Referral code usage logged successfully.")
            }
        }
    }
}

struct ReferralCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralCodeView()
    }
}

