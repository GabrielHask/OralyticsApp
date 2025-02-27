import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct SignInView: View {
    @StateObject private var authManager = AuthManager()
    @State private var fadeIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToTabBar = false // State variable to control navigation
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var globalContent: GlobalContent
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Go back to the previous screen
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    Text("Create Your Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .opacity(fadeIn ? 1 : 0)
                        .animation(.easeIn(duration: 1), value: fadeIn)
                    Spacer()
                    Button(action: {
                        generateHapticFeedback()
                        signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text("Sign in with Google")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .frame(height: 50)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeIn(duration: 1).delay(0.5), value: fadeIn)
                    .padding(.horizontal, 20)

                    Text("OR")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)

                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            generateHapticFeedback()
                            switch result {
                            case .success(let authResults):
                                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                    signInWithApple(credential: appleIDCredential)
                                }
                            case .failure(let error):
                                print("Sign In with Apple failed: \(error.localizedDescription)")
                                alertMessage = "Sign In with Apple failed: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeIn(duration: 1).delay(1), value: fadeIn)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .onAppear {
                    fadeIn = true
                    setupAuthManager()
                }

                // NavigationLink to TabBarView
                NavigationLink(destination: TabBarView(selectedTab: $selectedTab).navigationBarHidden(true), isActive: $navigateToTabBar) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(.stack)
        .background(Color.white.ignoresSafeArea())
    }

    private func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    private func setupAuthManager() {
        authManager.onEmailProvided = { email in
            globalContent.email = email
            navigateToTabBar = true // Trigger navigation to TabBarView
        }
        authManager.onSignOut = {
            globalContent.email = nil
        }
    }

    private func signInWithGoogle() {
        authManager.signInWithGoogle()
    }

    private func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        authManager.signInWithApple(credential: credential)
    }
}
