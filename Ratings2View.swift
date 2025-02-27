import SwiftUI
import FirebaseFirestore

struct Ratings2View: View {
    let docID: String
    let globalImage: UIImage?
    @EnvironmentObject var globalContent: GlobalContent
    @State private var ratings2List: [[Int]] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            if let globalImage = globalImage {
                Image(uiImage: globalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 240, height: 240)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .shadow(radius: 8)
                    .padding(.top, 10)
                
            }

            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
            } else if let errorMessage = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if ratings2List.isEmpty {
                VStack {
                    Image(systemName: "star.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                    Text("No ratings available.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if let ratings2 = ratings2List.first {
                    FullScreenRatingGrid(
                        physiqueType: physiqueTypeDescription(ratings2[0]),
                        bodyType: bodyTypeDescription(ratings2[1]),
                        xFactorScore: ratings2[2],
                        swoleScore: ratings2[3]
                    )
                }
            }

            // The ShareButton and related UI have been removed.
        }
        .padding()
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchRatings2Data()
            // captureScreenshot() has been removed.
        }
    }

    func fetchRatings2Data() {
        isLoading = true
        errorMessage = nil

        guard let email = globalContent.email else {
            errorMessage = "User email not available."
            isLoading = false
            return
        }

        let db = Firestore.firestore()
        let userDoc = db.collection("userRatings").document(email)
        let timestampsCollection = userDoc.collection("timestamps")

        timestampsCollection.document(docID).getDocument { document, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }

            guard let document = document, document.exists else {
                self.errorMessage = "No data found."
                self.isLoading = false
                return
            }

            if let ratings2 = document.data()?["ratings2"] as? [Int] {
                self.ratings2List = [ratings2]
            } else {
                self.errorMessage = "Ratings data not found."
            }
            self.isLoading = false
        }
    }

    // The captureScreenshot function has been removed.

    func physiqueTypeDescription(_ value: Int) -> String {
        switch value {
        case 0: return "Poor"
        case 1: return "Moderate"
        case 2: return "Good"
        default: return "Unknown"
        }
    }

    func bodyTypeDescription(_ value: Int) -> String {
        switch value {
        case 0: return "Bright White"
        case 1: return "Moderate White"
        case 2: return "Darker White"
        default: return "Unknown"
        }
    }
}

struct FullScreenRatingGrid: View {
    let physiqueType: String
    let bodyType: String
    let xFactorScore: Int
    let swoleScore: Int

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) { // Reduced spacing
            RatingBox(label: "Teeth Whiteness", value: physiqueType, icon: "heart.fill", iconColor: .black, showProgress: false)
            RatingBox(label: "Ideal Teeth Shade", value: bodyType, icon: "figure.walk", iconColor: .black, showProgress: false)
            RatingBox(label: "Teeth Structure", value: "\(xFactorScore)", icon: "star.fill", iconColor: .black, showProgress: true, progress: Double(xFactorScore) / 100.0)
            RatingBox(label: "Dental Health", value: "\(swoleScore)", icon: "flame.fill", iconColor: .black, showProgress: true, progress: Double(swoleScore) / 100.0)
        }
        .padding(.horizontal, 16)
    }
}

struct RatingBox: View {
    let label: String
    let value: String
    let icon: String
    let iconColor: Color
    let showProgress: Bool
    var progress: Double = 0.0

    @State private var showingInfo = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) { // Reduced spacing
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title3) // Reduced from .title2
                    Text(label)
                        .font(.custom("Chalkboard SE", size: 11)) // Reduced font size
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.top, 4) // Reduced padding

                // Include ProgressView in all cases
                ProgressView(value: showProgress ? progress : 0)
                    .progressViewStyle(LinearProgressViewStyle(tint: showProgress ? .black : .clear))
                    .scaleEffect(x: 1, y: 2, anchor: .center) // Reduced scale
                    .padding(.top, 2) // Reduced padding
                    .opacity(showProgress ? 1 : 0) // Hide when not needed

                Text(value)
                    .font(.custom("Chalkboard SE", size: 18)) // Reduced font size
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 4) // Adjusted padding

                Spacer(minLength: 0) // Minimized spacer
            }
            .padding(12) // Reduced padding
            .frame(maxWidth: .infinity, minHeight: 120) // Reduced minHeight
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1) // Adjusted shadow
            )

            Button(action: { showingInfo.toggle() }) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.black)
                    .padding(4) // Reduced padding
            }
            .alert(isPresented: $showingInfo) {
                Alert(title: Text(label), message: Text(infoText(for: label)), dismissButton: .default(Text("OK")))
            }
        }
        .frame(minHeight: 140) // Reduced from 200
    }

    func infoText(for label: String) -> String {
        switch label {
        case "Teeth Whiteness": return "How white your teeth are."
        case "Ideal Teeth Shade": return "A rough estimate of the ideal shade for your teeth based on several factors."
        case "Teeth Structure": return "A measure of the overall structure of your teeth, including their alignment, spacing, and condition (is there chipping, irregular shapes, etc)."
        case "Smile Aesthetic": return "Overall rough estimate for the visual appearance of your teeth, mouth, and smile."
        default: return "Information not available."
        }
    }
}
