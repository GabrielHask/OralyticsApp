import SwiftUI
import GoogleSignIn
import SuperwallKit

struct ContentView: View {
    @StateObject private var globalContent = GlobalContent()
    @StateObject private var authManager = AuthManager()

    @State private var selectedTab = 0 // State variable to track selected tab index

    var body: some View {
        NavigationView {
            if let email = UserDefaults.standard.string(forKey: "email") {
                // User is signed in (email exists in UserDefaults)
                TabBarView(selectedTab: $selectedTab)
                    .environmentObject(globalContent) // Pass GlobalContent to TabBarView
                    .navigationBarHidden(true) // Hide navigation bar in TabBarView
            } else {
                // No email found, show StartPageView
                StartPageView()
                    .environmentObject(authManager) // Pass AuthManager to StartPageView
                    .navigationBarBackButtonHidden(true) // Hide back button in StartPageView
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            checkSignInStatus()
        }
        .animation(.easeInOut) // Ensure transitions are animated
    }

    private func checkSignInStatus() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let user = user {
                    // User is signed in
                    authManager.isSignedIn = true
                    globalContent.email = user.profile?.email // Set the email in GlobalContent
                } else if let error = error {
                    // Failed to restore sign-in
                    print("Failed to restore previous sign-in: \(error.localizedDescription)")
                    authManager.isSignedIn = false
                }
            }
        } else {
            authManager.isSignedIn = false
        }
    }

    private func triggerSuperwallStartEvent() {
        // Trigger the Superwall event here
        Superwall.shared.register(event: "start_trigger")
    }
}


