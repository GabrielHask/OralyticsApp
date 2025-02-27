
import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
import SuperwallKit

extension NSNotification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
    static let analysisStarted = Notification.Name("analysisStarted")
}

struct UploadPictureView: View {
    @Binding var reset: Bool
    @StateObject private var authManager = AuthManager()
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSettingsMenu = false
    @State private var showLogoutConfirmation = false
    @State private var navigateToStartPage = false
    @State private var showSurvey = false
    @State private var surveyResponse = ""
    @State private var selectedReason = ""
    @State private var otherReason = ""
    
    private let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyPolicyURL = URL(string: "https://cyber-cardigan-01b.notion.site/Privacy-Policy-143d49b7c7a58028a8d3d45ba84d4d62?pvs=4")!
    
    private var bodyImage: UIImage {
        let gender = UserDefaults.standard.string(forKey: "selectedGender") ?? "male"
        return UIImage(named: gender == "female" ? "FemaleBodyImage" : "BodyImage")!
    }

    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                VStack(spacing: 16) {
                    Text("Upload a Picture of Your Teeth")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    
                    Text("With the selfie camera, take a picture of you showing your teeth and gums")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    Image(uiImage: selectedImage ?? bodyImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 350, height: 350) // Larger size
                        .clipped()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    
                    Button(action: {
                        generateHapticFeedback()
                        showActionSheet = true
                    }) {
                        Text(selectedImage != nil ? "Use Another" : "Upload or Take a Picture")
                            .font(.custom("Inter-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(title: Text("Select Photo"), message: nil, buttons: [
                            .default(Text("Take a Picture")) {
                                generateHapticFeedback()
                                imagePickerSource = .camera
                                showImagePicker = true
                            },
                            .default(Text("Choose an Existing Image")) {
                                generateHapticFeedback()
                                imagePickerSource = .photoLibrary
                                showImagePicker = true
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: imagePickerSource, selectedImage: $selectedImage)
                    }
                    
                    if selectedImage != nil {
                        Button(action: {
                            generateHapticFeedback()
                            NotificationCenter.default.post(name: .analysisStarted, object: nil)
                            navigateToStartPage = true
                        }) {
                            Text("Continue")
                                .font(.custom("Inter-Bold", size: 18))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                    }
                    
                    Button(action: {
                                    if let url = URL(string: "https://cyber-cardigan-01b.notion.site/About-Oralytics-146d49b7c7a58045857def77bc519f29?pvs=4") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Disclaimer and Citations")
                                        .font(.custom("inter-Regular", size: 14)) // You can adjust the font to match the style in your image
                                        .foregroundColor(.gray)
                                        .underline()
                                }
                                .padding(.bottom, 6)
                    
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingsButton
                    }
                }
                .background(Color.white.ignoresSafeArea())
                .onChange(of: reset) { newValue in
                    if newValue {
                        selectedImage = nil
                    }
                }
            }
            .tabBarHidden(false)
            .background(Color.white.ignoresSafeArea())
        }
    }

    private var settingsButton: some View {
        Button(action: {
            generateHapticFeedback()
            showSettingsMenu.toggle()
        }) {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.black) // Make the gear icon black
                .padding()
                .accessibility(label: Text("Settings"))
        }
        .actionSheet(isPresented: $showSettingsMenu) {
            ActionSheet(title: Text("Settings"), buttons: [
                .destructive(Text("Delete Account")) {
                    generateHapticFeedback()
                    showLogoutConfirmation = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showLogoutConfirmation) {
            VStack {
                if !showSurvey {
                    // Original account deletion confirmation UI
                    Text("Are you sure you want to delete your account?")
                        .font(.custom("Inter-Bold", size: 18))
                        .padding()
                    HStack {
                        Button("Cancel") {
                            generateHapticFeedback()
                            showLogoutConfirmation = false
                        }
                        .font(.custom("Inter-Regular", size: 16))
                        .padding()
                        Button("Delete") {
                            generateHapticFeedback()
                            Superwall.shared.register(event: "delete_trigger")
                            showSurvey = true
                        }
                        .font(.custom("Inter-Bold", size: 16))
                        .padding()
                    }
                } else {
                    // Improved Survey UI
                    VStack {
                        Text("We're sorry to see you go!")
                            .font(.custom("Inter-Bold", size: 22))
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                        
                        Text("Could you tell us why you're leaving?")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)

                        // Reason Picker
                        Picker("Please select a reason:", selection: $selectedReason) {
                            Text("Price").tag("Price")
                            Text("Inaccuracy").tag("Inaccuracy")
                            Text("Advice").tag("Workout Plan")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .font(.custom("Inter-Regular", size: 16))

                        // Additional reason text field for "Other"
                        if selectedReason == "Other" {
                            TextField("Please specify", text: $otherReason)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .font(.custom("Inter-Regular", size: 16))
                        }

                        // Improvement suggestion
                        Text("How can we improve?")
                            .font(.custom("Inter-Bold", size: 18))
                            .padding(.top, 10)

                        TextField("Your feedback", text: $surveyResponse)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .font(.custom("Inter-Regular", size: 16))

                        // Action Buttons
                        HStack {
                            Button(action: {
                                generateHapticFeedback()
                                saveSurveyResponse()
                                authManager.signOut()
                                showLogoutConfirmation = false
                                navigateToStartPage = true

                                NotificationCenter.default.post(name: .userDidLogout, object: nil)
                            }) {
                                Text("Submit")
                                    .font(.custom("Inter-Bold", size: 16))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)

                            Button(action: {
                                generateHapticFeedback()
                                authManager.signOut()
                                showLogoutConfirmation = false
                                navigateToStartPage = true
                                NotificationCenter.default.post(name: .userDidLogout, object: nil)
                            }) {
                                Text("Skip")
                                    .font(.custom("Inter-Bold", size: 16))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        Text("Note: Manage subscription in Apple Settings")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
    }

    private func saveSurveyResponse() {
        let userDefaults = UserDefaults.standard
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("No email found in UserDefaults.")
            return
        }
        
        let db = Firestore.firestore()
        let surveyData: [String: Any] = [
            "email": email,
            "reason": selectedReason,
            "otherReason": otherReason,
            "improvementSuggestion": surveyResponse,
            "timestamp": Timestamp()
        ]
        
        db.collection("surveyResponses").addDocument(data: surveyData) { error in
            if let error = error {
                print("Error saving survey response: \(error.localizedDescription)")
            } else {
                print("Survey response saved successfully.")
            }
        }
    }
}

extension View {
    func tabBarHidden(_ hidden: Bool) -> some View {
        self.modifier(TabBarModifier(isHidden: hidden))
    }
}

struct TabBarModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isHidden {
                VStack {
                    Spacer()
                    Divider()
                        .opacity(0)
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    @EnvironmentObject var globalContent: GlobalContent

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        
        if sourceType == .camera {
            picker.cameraDevice = .front
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                if let imageData = image.pngData() {
                    parent.globalContent.globalImage = imageData // Save image to GlobalContent
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
