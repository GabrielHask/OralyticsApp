import SwiftUI
import UIKit

struct ImageDetailView: View {
    let docID: String
    let rating: [Int]
    let globalImage: UIImage?
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode

    init(docID: String, rating: [Int], globalImage: UIImage?) {
        self.docID = docID
        self.rating = rating
        self.globalImage = globalImage
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            TabView(selection: $selectedTab) {
                ImageDetailContentView(docID: docID, rating: rating, globalImage: globalImage)
                    .tag(0)
                Ratings2View(docID: docID, globalImage: globalImage)
                    .tag(1)
                RatingSummaryView(
                    globalImage: globalImage,
                    overallRating: calculateOverall(rating),
                    percentile: calculatePercentile(overallRating: calculateOverall(rating))
                )
                .tag(2)
            }
            .background(Color.white.ignoresSafeArea())
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            .overlay(
                PageControlOverlay(currentPage: $selectedTab, totalPages: 3),
                alignment: .bottom
            )
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            )
            .navigationViewStyle(.stack)
        }
    }

    // Function to calculate overall score
    func calculateOverall(_ rating: [Int]) -> Int {
        guard !rating.isEmpty else { return 0 }
        return rating.reduce(0, +) / rating.count
    }

    // Function to calculate the percentile based on the overall rating with a slight right skew
    func calculatePercentile(overallRating: Int) -> Double {
        switch overallRating {
        case 0...10:
            return Double(overallRating) / 10.0 * 12.0
        case 11...20:
            return 12.0 + (Double(overallRating - 10) / 10.0 * 10.0)
        case 21...30:
            return 22.0 + (Double(overallRating - 20) / 10.0 * 10.0)
        case 31...40:
            return 32.0 + (Double(overallRating - 30) / 10.0 * 10.0)
        case 41...50:
            return 42.0 + (Double(overallRating - 40) / 10.0 * 10.0)
        case 51...60:
            return 52.0 + (Double(overallRating - 50) / 10.0 * 10.0)
        case 61...70:
            return 62.0 + (Double(overallRating - 60) / 10.0 * 10.0)
        case 71...80:
            return 72.0 + (Double(overallRating - 70) / 10.0 * 10.0)
        case 81...90:
            return 82.0 + (Double(overallRating - 80) / 10.0 * 10.0)
        case 91...100:
            return 92.0 + (Double(overallRating - 90) / 10.0 * 8.0)
        default:
            return 0.0
        }
    }
}

struct PageControlOverlay: View {
    @Binding var currentPage: Int
    let totalPages: Int

    var body: some View {
        ZStack {
            // Gray oval background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.8))
                .frame(width: CGFloat(totalPages) * 20, height: 30)

            // Dots representing the pages
            HStack(spacing: 10) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .frame(width: currentPage == index ? 14 : 10, height: currentPage == index ? 14 : 10)
                        .foregroundColor(currentPage == index ? .black : .white)
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .frame(width: CGFloat(totalPages) * 20, height: 30)
        }
        .padding(.bottom, 30)
    }
}

struct ImageDetailContentView: View {
    let docID: String
    let rating: [Int]
    let globalImage: UIImage?
    @State private var capturedImage: UIImage? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showSharePopup: Bool = false // State variable for pop-up
    @State private var hasCapturedScreenshot: Bool = false // Prevent multiple captures

    private var ratingLabels: [String] {
        ["Color", "Alignment", "Teeth Condition", "Plaque Buildup", "Cavities", "Symmetry"]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack { // Use ZStack to overlay the pop-up
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 10) { // Reduced spacing from 20 to 10
                                // Assign an ID to the top of the ScrollView content
                                Color.clear
                                    .frame(height: 0)
                                    .id("Top")

                                if let globalImage = globalImage {
                                    Image(uiImage: globalImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        // Increased the size multiplier from 0.35 to 0.5 to enlarge the image
                                        .frame(width: geometry.size.width * 0.40, height: geometry.size.width * 0.40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                        .shadow(radius: 4)
                                        .padding(.top, 10)
                                }

                                // Overall and Potential ratings
                                HStack(spacing: 20) {
                                    OverallRatingView(overallRating: calculateOverall(Array(rating.dropLast())))
                                    PotentialRatingView(potentialRating: rating.last ?? 0)
                                }
                                .frame(maxWidth: geometry.size.width * 0.9, alignment: .center)
                                .padding(.vertical, 5)

                                // Display individual ratings
                                RatingsListView(ratings: Array(rating.dropLast()), labels: ratingLabels)
                                    .padding(.horizontal, 15)
                            }
                            .frame(width: geometry.size.width, alignment: .top)
                            .background(Color.white)
                            .onAppear {
                                // Store the proxy for later use if needed
                                scrollProxy = proxy

                                // Capture the screenshot immediately if not already done
                                if !hasCapturedScreenshot {
                                    hasCapturedScreenshot = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                        captureScreenshot()

                                    }
                                    
                                    // Schedule the pop-up to appear after 1 second
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        withAnimation {
                                            showSharePopup = true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // "Share Results" Button removed
                }

                // Pop-up overlay
                if showSharePopup, let _ = capturedImage {
                    SharePopupView(capturedImage: $capturedImage, isPresented: $showSharePopup)
                        .transition(.scale)
                        .zIndex(1) // Ensure the pop-up is above other views
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    // Function to calculate overall score
    func calculateOverall(_ rating: [Int]) -> Int {
        guard !rating.isEmpty else { return 0 }
        return rating.reduce(0, +) / rating.count
    }

    // Function to capture screenshot and show the pop-up
    func captureScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let image = renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        capturedImage = image
    }
}

struct SharePopupView: View {
    @Binding var capturedImage: UIImage? // Changed from let to @Binding
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Dismiss the pop-up when tapping outside
                    withAnimation {
                        isPresented = false
                    }
                }

            // Pop-up content
            VStack(spacing: 20) {
                Text("Share Your Results")
                    .font(.headline)
                    .foregroundColor(.white)

                if let capturedImage = capturedImage {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10)
                }

                // ShareButton remains if you want to allow sharing functionality
                ShareButton(capturedImage: $capturedImage)

                Button(action: {
                    // Dismiss the pop-up
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.8))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(40)
        }
    }
}

struct PotentialRatingView: View {
    let potentialRating: Int

    var body: some View {
        VStack {
            Text("\(potentialRating)")
                .font(.custom("Chalkboard SE", size: 45))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Smile Aesthetic")
                .font(.custom("Chalkboard SE", size: 24))
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct RatingSummaryView: View {
    let globalImage: UIImage?
    let overallRating: Int
    let percentile: Double

    var body: some View {
        GlobalContentView(
            globalImage: globalImage,
            overallRating: overallRating,
            percentile: percentile / 100
        )
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
}

struct ImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetailView(
            docID: "12345",
            rating: [85, 70, 90, 80, 95, 88, 92],
            globalImage: UIImage(named: "exampleImage")
        )
        .previewDevice("iPhone 14")
    }
}
