import SwiftUI
import UIKit
import SuperwallKit
import Firebase
import FirebaseFirestore
import MessageUI
import Combine

// MARK: - AppState

/// ObservableObject to manage shared state across views.
class AppState: ObservableObject {
    /// Published property to signal when the share sheet should be dismissed.
    @Published var shouldDismissShareSheet: Bool = false
}

// MARK: - PaymentView

import SwiftUI
import UIKit
import SuperwallKit
import FirebaseFirestore
import MessageUI
import Combine

// ... [Other code remains unchanged]

// MARK: - PaymentView

struct PaymentView: View {
    let globalImage: UIImage? // Profile image to display
    @State private var isUmaxProActive: Bool = false
    @State private var showInviteSheet: Bool = false
    @StateObject private var appState = AppState() // Initialize AppState
    @State private var selectedTab = 1 // Track the selected tab

    private let blurredRatings: [String] = [
        "Overall", "Color", "Alignment", "Tooth/Surface Conditions", "Plaque Buildup", "Cavities", "Tooth Shape"
    ]

    // Define grid layout with 2 columns
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Spacer() // Top flexible space

                    // Title and Subtitle with Eyes Emoji
                    VStack(spacing: 8) {
                        Text("👀 Get your results")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Get Oralytics Pro or Invite 3 Friends")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.headline)
                                Text("Improve your dental health and aesthetic")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)

                    Spacer() // Space between title and profile image

                    // Profile Image
                    if let globalImage = globalImage {
                        Image(uiImage: globalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    }

                    Spacer() // Space between profile image and ratings grid

                    // Blurred Ratings Grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(blurredRatings, id: \.self) { rating in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(rating)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                // Blurred progress bar
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 10)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer() // Space between ratings grid and buttons

                    
                    // Buttons VStack
                    VStack(spacing: 15) {
                        // Umax Pro Button
                        Button(action: {
                            Task {
                                Superwall.shared.register(event: "tab_trigger")
                                let result = await Superwall.shared.getPresentationResult(forEvent: "tab_trigger")
                                print("Superwall result: \(result)")
                                switch result {
                                case .userIsSubscribed:
                                    isUmaxProActive = true
                                    print("User is subscribed. Navigating to TabBarView.")
                                case .paywall:
                                    isUmaxProActive = true
                                    print("Paywall presented.")
                                case .holdout:
                                    print("User is in holdout group.")
                                case .eventNotFound, .noRuleMatch, .paywallNotAvailable:
                                    print("Event not found or no rule match.")
                                }
                            }
                        }) {
                            Text("Get Oralytics Pro")
                                .font(.system(size: 20, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 6)
                        }

                        // Invite Friends Button
//                        Button(action: {
//                            showInviteSheet = true
//                        }) {
//                            Text("Invite 3 Friends")
//                                .font(.system(size: 20, weight: .bold))
//                                .frame(maxWidth: .infinity, minHeight: 60)
//                                .background(Color.white)
//                                .foregroundColor(.black)
//                                .cornerRadius(12)
//                                .shadow(radius: 6)
//                        }
//                        .sheet(isPresented: $showInviteSheet) {
//                            InviteFriendsSheet(isUmaxProActive: $isUmaxProActive)
//                                .environmentObject(appState)
//                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer() // Bottom flexible space

                    // Hidden NavigationLink for Navigation to TabBarView
                    NavigationLink(
                        destination: TabBarView(selectedTab: $selectedTab).navigationBarHidden(true),
                        isActive: $isUmaxProActive
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                )
            }
            .navigationTitle("") // Remove the navigation title
            .navigationBarHidden(true) // Hide the navigation bar if not needed
        }
        .task {
            let result1 = await Superwall.shared.getPresentationResult(forEvent: "tab_trigger")
            if(result1 == .userIsSubscribed)
            {
                DispatchQueue.main.async {
                    isUmaxProActive = true
                }
            }
        }
    }
}

// ... [Rest of the code remains unchanged]


struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(globalImage: UIImage(systemName: "person.circle")) // Example image
    }
}

// MARK: - InviteFriendsSheet

struct InviteFriendsSheet: View {
    @Binding var isUmaxProActive: Bool // Binding to modify isUmaxProActive in PaymentView
    @EnvironmentObject var appState: AppState // Observe AppState
    @Environment(\.presentationMode) var presentationMode // Access presentation mode to dismiss
    @State private var isShowingShareSheet: Bool = false // State to control share sheet
    @State private var referralCode: String = "" // State for the referral code
    @State private var redeemMessage: String = "" // State to display success or error messages
    @State private var isCopied: Bool = false // State to control clipboard button animation
    private let db = Firestore.firestore() // Firestore instance
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text("Invite 3 Friends")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("Share the app with 3 friends to unlock your results!")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Display the referral code prominently
                VStack(spacing: 15) {
                    Text("Your Referral Code")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("\(referralCode)")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        
                        // Animated Clipboard Button
                        Button(action: {
                            UIPasteboard.general.string = referralCode // Copy referral code to clipboard
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isCopied = true
                            }
                            // Revert the animation after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isCopied = false
                                }
                            }
                        }) {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.title2)
                                .foregroundColor(isCopied ? .green : .black)
                                .scaleEffect(isCopied ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isCopied)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                // Share Invite Button
                Button(action: {
                    isShowingShareSheet = true // Show the share sheet
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text("Share Invite")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
                }
                .padding(.horizontal)
                .sheet(isPresented: $isShowingShareSheet) {
                    // Present the share sheet using ActivityView
                    ActivityView(activityItems: ["Check out this app, Oralytics, and use my code \(referralCode) to get your teeth analyzed"])
                }
                
                Spacer()
                
                // Redeem Message
                if !redeemMessage.isEmpty {
                    Text(redeemMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(redeemMessage.contains("Success") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 3)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.white)
            .navigationBarTitle("Invite Friends", displayMode: .inline)
            .navigationBarItems(trailing:
                                    // Redeem Button
                                Button(action: {
                redeemOwnReferralCode()
            }) {
                Text("Redeem")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
            }
            )
            .onAppear {
                loadReferralCode() // Load referral code when the sheet appears
                checkOwnReferralCodeUsageCount() // Check the usage count of user's own referral code
            }
            .onReceive(appState.$shouldDismissShareSheet) { shouldDismiss in
                if shouldDismiss {
                    isShowingShareSheet = false // Dismiss the share sheet
                    // Reset the flag to avoid repeated dismissals
                    DispatchQueue.main.async {
                        appState.shouldDismissShareSheet = false
                    }
                }
            }
        }
    }
    // Function to load referral code from UserDefaults or generate a new one
    func loadReferralCode() {
        if let savedReferralCode = UserDefaults.standard.string(forKey: "referralCode") {
            referralCode = savedReferralCode // Use the saved referral code
        } else {
            generateReferralCode() // Generate and save a new referral code
        }
    }
    
    // Function to generate a random 6-digit referral code and save to UserDefaults
    func generateReferralCode() {
        referralCode = String(format: "%06d", Int.random(in: 100000...999999))
        UserDefaults.standard.set(referralCode, forKey: "referralCode") // Save to UserDefaults
        saveReferralCodeToFirestore() // Save the code to Firestore
    }
    
    // Function to save the referral code to Firestore
    func saveReferralCodeToFirestore() {
        let referralData: [String: Any] = [
            "UsageCount": 0
        ]
        
        db.collection("ReferralCodes").document(referralCode).setData(referralData) { error in
            if let error = error {
                print("Error saving referral code: \(error.localizedDescription)")
            } else {
                print("Referral code saved successfully.")
            }
        }
    }
    
    // Function to check the user's own referral code's UsageCount
    func checkOwnReferralCodeUsageCount() {
        guard !referralCode.isEmpty else {
            print("Referral code is empty.")
            return
        }
        
        db.collection("ReferralCodes").document(referralCode).getDocument { (document, error) in
            if let error = error {
                print("Error fetching referral code: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    redeemMessage = "Error fetching referral code."
                }
                return
            }
            
            if let document = document, document.exists {
                if let usageCount = document.data()?["UsageCount"] as? Int {
                    if usageCount >= 3 {
                        DispatchQueue.main.async {
                            isUmaxProActive = true
                            redeemMessage = "Success! Your referral code has been used \(usageCount) times. Oralytics Pro is now active!"
                            print("Your referral code has been used \(usageCount) times. Oralytics Pro is now active!")
                            
                            // Dismiss the sheet
                            presentationMode.wrappedValue.dismiss()
                            
                            // Reset UsageCount to 0 after successful redemption
                            db.collection("ReferralCodes").document(referralCode).updateData(["UsageCount": 0]) { error in
                                if let error = error {
                                    print("Error resetting UsageCount: \(error.localizedDescription)")
                                    // Optionally, update redeemMessage to inform the user
                                    DispatchQueue.main.async {
                                        redeemMessage = "Redeemed successfully, but failed to reset UsageCount."
                                    }
                                } else {
                                    print("UsageCount reset to 0.")
                                    // Optionally, update redeemMessage to confirm reset
                                    DispatchQueue.main.async {
                                        redeemMessage += " Usage count has been reset."
                                    }
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            redeemMessage = "Your referral code has been used \(usageCount) times."
                            print("Your referral code has been used \(usageCount) times.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Error retrieving usage count.")
                        redeemMessage = "Error retrieving usage count."
                    }
                }
            } else {
                // Document does not exist; create it with UsageCount set to 0
                print("Referral code does not exist in Firestore. Creating new document with UsageCount = 0.")
                let referralData: [String: Any] = [
                    "UsageCount": 0
                ]
                
                db.collection("ReferralCodes").document(referralCode).setData(referralData) { error in
                    if let error = error {
                        print("Error creating referral code: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            redeemMessage = "Error creating referral code."
                        }
                    } else {
                        print("Referral code created with UsageCount set to 0.")
                        DispatchQueue.main.async {
                            redeemMessage = "Referral code created. Usage count is 0."
                        }
                    }
                }
            }
        }
    }
    
    // Function to redeem own referral code by checking UsageCount
    func redeemOwnReferralCode() {
        // Directly check the UsageCount from Firestore
        checkOwnReferralCodeUsageCount()
    }
}

struct InviteFriendsSheet_Previews: PreviewProvider {
    @State static var isUmaxProActive: Bool = false
    
    static var previews: some View {
        InviteFriendsSheet(isUmaxProActive: $isUmaxProActive)
            .environmentObject(AppState())
            .previewDevice("iPhone 14")
    }
}

// MARK: - ActivityView

/// Wrapper for UIActivityViewController to use in SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activityItems: ["Sample text to share"])
            .previewDevice("iPhone 14")
    }
}

// MARK: - TabBarView_Previews

struct TabBarView_Previews: PreviewProvider {
    @State static var selectedTab: Int = 1
    
    static var previews: some View {
        TabBarView(selectedTab: $selectedTab)
            .previewDevice("iPhone 14")
    }
}

// Note: Ensure that TabBarView is defined in your project. If not, you might need to implement it or remove the preview.
