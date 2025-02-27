//
//  AuthManager.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import Combine

class AuthManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    
    var onEmailProvided: ((String) -> Void)?
    var onSignOut: (() -> Void)?

    private let userDefaults = UserDefaults.standard

    override init() {
        super.init()
        checkIfSignedIn() // Check if the user is signed in when the class is initialized
    }

    private func checkIfSignedIn() {
        if let email = userDefaults.string(forKey: "email") {
            print("User is signed in with email: \(email)")
            isSignedIn = true
        } else {
            print("No user is signed in.")
        }
    }

    func signInWithGoogle() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            print("Error: No presenting view controller found.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            if let error = error {
                print("Error signing in with Google: \(error.localizedDescription)")
                return
            }

            guard let signInResult = signInResult else {
                print("Sign-in result is nil.")
                return
            }

            if let email = signInResult.user.profile?.email, !email.isEmpty {
                print("Email from Google sign-in: \(email)")
                self?.handleEmailProvided(email)
            } else {
                print("Error: Google sign-in returned no email.")
            }
        }
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        print("Sign in with Apple credential received")
        
        if let email = credential.email, !email.isEmpty {
            print("Email from Apple sign-in: \(email)")
            handleEmailProvided(email)
        } else {
            // If Apple doesn't provide an email (e.g., for existing accounts)
            let userIdentifier = credential.user
            let dummyEmail = "\(userIdentifier)@appleId.com" // Using user ID to create a dummy email
            print("No email provided by Apple. Using dummy email: \(dummyEmail)")
            handleEmailProvided(dummyEmail)
        }
    }

    private func handleEmailProvided(_ email: String) {
        guard !email.isEmpty else {
            print("Error: Email is empty. Cannot proceed.")
            return
        }
        
        print("Handling email: \(email)")
        userDefaults.set(email, forKey: "email") // Ensure email is saved in UserDefaults
        userDefaults.synchronize() // Synchronize UserDefaults (optional but helps ensure the data is written)
        
        isSignedIn = true
        onEmailProvided?(email) // Trigger callback if any
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut() // Sign out from Google
        userDefaults.removeObject(forKey: "email") // Remove email from UserDefaults
        userDefaults.synchronize() // Synchronize changes
        
        print("User signed out. Email removed from UserDefaults.")
        self.isSignedIn = false
        self.onSignOut?() // Trigger sign-out callback
    }

    func deleteAccount() {
        guard let email = userDefaults.string(forKey: "email") else {
            print("No email found for account deletion.")
            return
        }
        
        print("Attempting to delete account with email: \(email)")
        // Add logic for deleting the account from the backend if necessary
        
        signOut() // Sign out the user and clear UserDefaults
    }
}
