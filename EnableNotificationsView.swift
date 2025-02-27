import SwiftUI
import UserNotifications

struct EnableNotificationsView: View {
    @State private var isNotificationEnabled = false
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                
                
                
                Text("Enable Notifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                
                Image(systemName: "bell.and.waves.left.and.right.fill") // Replace with the name of your image in assets
                    .resizable()
                    .foregroundStyle(Color.black)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("To get the most out of our app, please enable notifications.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding()
                
                Button(action: {
                    requestNotificationAuthorization()
                }) {
                    Text("Enable Notifications")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
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
                // The "Continue" button is always enabled
                // Optionally, you can provide a message or change the button's style based on notification status
                
                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
            //  .padding()
            .onAppear {
                checkNotificationAuthorization()
            }
            .background(
                NavigationLink(destination: AppRatingsView().navigationBarHidden(true), isActive: $navigateToNextView) {
                    EmptyView()
                }
                .navigationViewStyle(.stack)

            )
        }
    }

    private func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                isNotificationEnabled = granted
                // Navigate to the next view regardless of notification permissions
                navigateToNextView = true
            }
        }
    }

    private func checkNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}

struct EnableNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        EnableNotificationsView()
    }
}
