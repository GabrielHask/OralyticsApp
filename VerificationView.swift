import SwiftUI
import Contacts
import MessageUI

// Placeholder for EnableNotificationsView


// MessageComposeView remains unchanged
struct MessageComposeView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var recipients: [String]
    var message: String
    var onResult: (Result<MessageComposeResult, Error>) -> Void

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(parent: MessageComposeView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                switch result {
                case .cancelled:
                    self.parent.onResult(.success(.cancelled))
                case .sent:
                    self.parent.onResult(.success(.sent))
                case .failed:
                    self.parent.onResult(.failure(NSError(domain: "Message failed", code: 0, userInfo: nil)))
                @unknown default:
                    self.parent.onResult(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = recipients
        vc.body = message
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}

struct Contact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let phoneNumber: String
}

struct ShareToContactsView: View {
    @Binding var isPresented: Bool
    @Binding var contacts: [Contact]
    var userRank: Int
    var onSendComplete: () -> Void // Callback to notify when sending is complete

    @State private var selectedContacts: Set<Contact> = []
    @State private var showMessageCompose: Bool = false
    @State private var messageComposeRecipients: [String] = []
    @State private var showMessageAlert: Bool = false
    @State private var messageAlertMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Invite 3 friends to your fitness journey")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)

            ScrollView {
                ForEach(contacts, id: \.self) { contact in
                    ContactRow(contact: contact, isSelected: selectedContacts.contains(contact))
                        .onTapGesture {
                            toggleSelection(for: contact)
                        }
                }
            }
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding([.horizontal, .bottom], 20)

            Button(action: {
                sendMessages()
            }) {
                Text("Send")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedContacts.isEmpty ? Color.gray : Color.white)
                    .cornerRadius(10)
                    .padding([.horizontal, .bottom], 20)
            }
            .disabled(selectedContacts.isEmpty)
        }
        .background(Color.black)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .sheet(isPresented: $showMessageCompose) {
            MessageComposeView(recipients: messageComposeRecipients,
                               message: "I'm starting my dental journey with Oralytics. Download it to improve your teeth with me! ") { result in
                // No action needed here since navigation is handled immediately
            }
        }
        .alert(isPresented: $showMessageAlert) {
            Alert(title: Text("Message Status"), message: Text(messageAlertMessage), dismissButton: .default(Text("OK")) {
                // No action needed here since navigation is already handled
            })
        }
    }

    private func toggleSelection(for contact: Contact) {
        if selectedContacts.contains(contact) {
            selectedContacts.remove(contact)
        } else {
            selectedContacts.insert(contact)
        }
    }

    private func sendMessages() {
        // Prepare the recipients' phone numbers (limit to 3 friends)
        messageComposeRecipients = Array(selectedContacts.prefix(3)).map { $0.phoneNumber }

        if MFMessageComposeViewController.canSendText() {
            showMessageCompose = true
        } else {
            messageAlertMessage = "Your device is not configured to send messages."
            showMessageAlert = true
        }

        // Trigger navigation immediately after clicking Send
        onSendComplete()
    }
}

struct ContactRow: View {
    var contact: Contact
    var isSelected: Bool

    var body: some View {
        HStack {
            Text(contact.name)
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 10)
    }
}

struct VerificationView: View {
    // MARK: - State Variables
    @State private var showSharePopup: Bool = false
    @State private var contacts: [Contact] = []
    @State private var contactsAccessDenied: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    // To store user's rank, assuming you have a way to get it
    @State private var userRank: Int = 1 // Replace with actual rank logic

    // Navigation
    @State private var navigateToEnableNotifications: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Dark gray gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color(.darkGray), Color(.black)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    // "Let's motivate you!" text
                    Text("Let's motivate you!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)

                    // Contact verification box
                    VStack(spacing: 0) {
                        Text("Allow Contact Verification")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top, 15)

                        // Centered message text
                        Text("So you can share workouts and invite friends on your fitness journey.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)

                        Divider()

                        Button(action: requestContactPermission) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12) // Adjust padding to resemble Apple’s button style
                        }
                        .background(Color.white)
                    }
                    .frame(width: 320, height: 180) // Set frame size to resemble Apple's default message pop-up
                    .background(Color.white)
                    .cornerRadius(15) // Apple-style rounded corners
                    .shadow(radius: 10)
                    .padding()

                    Spacer()
                }

                // Share Popup Overlay
                if showSharePopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Dismiss when tapping outside
                            showSharePopup = false
                        }

                    ShareToContactsView(
                        isPresented: $showSharePopup,
                        contacts: $contacts,
                        userRank: userRank,
                        onSendComplete: {
                            navigateToEnableNotifications = true
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }

                // Alert for Contacts Access Denied
                if contactsAccessDenied {
                    VStack {
                        Spacer()
                        VStack(spacing: 20) {
                            Text("Contacts Access Denied")
                                .font(.headline)
                                .foregroundColor(.black)

                            Text("Please enable contacts access in Settings to share your rank with friends.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .foregroundColor(.gray)

                            Button(action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }) {
                                Text("Open Settings")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.horizontal, 32)
                        Spacer()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: contactsAccessDenied)
                }

                // Hidden NavigationLink for programmatic navigation
                NavigationLink(
                    destination: EnableNotificationsView().navigationBarBackButtonHidden(true),
                    isActive: $navigateToEnableNotifications,
                    label: {
                        EmptyView()
                    })
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button("Skip") {
                    navigateToEnableNotifications = true
                }
                .foregroundColor(.blue)
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Functions

    /// Requests access to the user's contacts
    private func requestContactPermission() {
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

        switch authorizationStatus {
        case .authorized:
            fetchContacts()
            showSharePopup = true
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        fetchContacts()
                        showSharePopup = true
                    } else {
                        contactsAccessDenied = true
                    }
                }
            }
        case .denied, .restricted:
            contactsAccessDenied = true
        @unknown default:
            contactsAccessDenied = true
        }
    }

    /// Fetches the user's contacts
    private func fetchContacts() {
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

        var fetchedContacts: [Contact] = []

        do {
            try store.enumerateContacts(with: fetchRequest) { (cnContact, stop) in
                let fullName = "\(cnContact.givenName) \(cnContact.familyName)"
                for phoneNumber in cnContact.phoneNumbers {
                    let number = phoneNumber.value.stringValue
                    // Optional: Format the phone number as needed
                    fetchedContacts.append(Contact(name: fullName, phoneNumber: number))
                }
            }
            DispatchQueue.main.async {
                self.contacts = fetchedContacts
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
            DispatchQueue.main.async {
                alertMessage = "Failed to fetch contacts. Please try again."
                showAlert = true
            }
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
    }
}
