import SwiftUI
import FirebaseFirestore
import Charts

struct ImageData {
    let image: UIImage
    let docID: String
    let ratings: [Int]
    let timestamp: Timestamp
}


struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Main Header
            Text("Oralytics is designed for people like you!")
                .font(.custom("inter-Bold", size: 28))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // User Images
            GeometryReader { geometry in
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { index in
                        if let uiImage = UIImage(named: "image\(index)") {
                            // Display actual image if available
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: min((geometry.size.width - 50) / 5, 60), height: min((geometry.size.width - 50) / 5, 60))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        } else {
                            // Placeholder for missing images
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: min((geometry.size.width - 50) / 5, 60), height: min((geometry.size.width - 50) / 5, 60))
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .scaleEffect(0.5)
                                )
                        }
                    }
                }
                .frame(width: geometry.size.width)
            }
            .frame(height: 70) // Fixed height for the image row

            Text("Oralytics Users")
                .font(.custom("inter-Regular", size: 20))
                .foregroundColor(.gray)

            // Effectiveness Message
            Text("Effective for 98% of Users after just 3 WEEKS")
                .font(.custom("inter-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text("The daily routine plans we provide are very effective and can be persisted.")
                .font(.custom("inter-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Loading Indicator
            VStack(spacing: 15) {
                Text("Loading Your History")
                    .font(.custom("inter-Bold", size: 20))
                    .foregroundColor(.black)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.black, lineWidth: 6)
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                        .onAppear {
                            isAnimating = true
                        }
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}







struct HistoryView: View {
    @EnvironmentObject var globalContent: GlobalContent
    @StateObject private var viewModel = HistoryViewModel()
    @State private var isLoading = true
    @State private var loadingAnimation = false

    private var ratingLabels: [String] {
        let selectedGender = UserDefaults.standard.string(forKey: "selectedGender") ?? "male"
        let labels: [String] = selectedGender == "male" ? ["Color", "Alignment", "Tooth/Surface Conditions", "Plaque Buildup", "Cavities", "Tooth Shape"] : ["Color", "Alignment", "Tooth/Surface Conditions", "Plaque Buildup", "Cavities", "Tooth Shape"]
        return ["Overall"] + labels
    }

    @State private var selectedRatingIndex = 0
    @State private var progress: Double = 0.0

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    if isLoading {
                        LoadingView()

                    } else {
                        if !viewModel.ratingDataPoints.isEmpty {
                            VStack(spacing: 10) {
                                HStack {
                                    Spacer()
                                    Menu {
                                        ForEach(0..<ratingLabels.count, id: \.self) { index in
                                            Button(action: {
                                                selectedRatingIndex = index
                                                viewModel.updateRatingDataPoints(for: selectedRatingIndex)
                                            }) {
                                                Text("\(ratingLabels[index]) Progress")
                                                    .font(.custom("inter-Regular", size: 18))
                                            }
                                        }
                                    } label: {
                                        // Black capsule with white text and arrow icon
                                        HStack(spacing: 4) {
                                            Image(systemName: "chevron.down") // Down arrow before the label text
                                                .foregroundColor(.white)
                                                .font(.system(size: 14, weight: .bold))

                                            Text("\(ratingLabels[selectedRatingIndex])")
                                                .font(.custom("inter-Bold", size: 18))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 16)
                                        .frame(minWidth: 140) // Ensures capsule is wide enough for both the arrow and label
                                        .background(Color.black)
                                        .clipShape(Capsule())

                                        Text("Progress")
                                            .font(.custom("inter-Bold", size: 24))
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                }







                                Chart {
                                    ForEach(viewModel.ratingDataPoints) { dataPoint in
                                        LineMark(
                                            x: .value("Date", dataPoint.date),
                                            y: .value("Rating", dataPoint.rating)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                        AxisTick()
                                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: .stride(by: 20)) { value in
                                        if let doubleValue = value.as(Double.self) {
                                            AxisTick()
                                            AxisValueLabel {
                                                Text("\(Int(doubleValue))")
                                                    .font(.custom("inter-Regular", size: 12))
                                            }
                                        }
                                    }
                                }
                                .chartYScale(domain: viewModel.yAxisRange)
                                .frame(height: 200)
                                .padding(.horizontal)
                            }

                            Text("Your Scans")
                                .font(.custom("inter-Bold", size: 24))
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                                .padding(.horizontal)

                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    if viewModel.imageData.isEmpty {
                                        emptyStateView
                                    } else {
                                        ForEach(viewModel.imageData, id: \.docID) { item in
                                            NavigationLink(destination: ImageDetailView(
                                                docID: item.docID,
                                                rating: item.ratings,
                                                globalImage: item.image
                                            ).navigationBarBackButtonHidden(true)) {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text("\(item.timestamp.dateValue(), formatter: dateFormatter)")
                                                        .font(.custom("inter-Regular", size: 16))
                                                        .foregroundColor(.primary)

                                                    Image(uiImage: item.image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(height: 200)
                                                        .clipped()
                                                        .cornerRadius(10)
                                                        .shadow(radius: 4)
                                                }
                                                .padding()
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(15)
                                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                                .padding(.horizontal)
                                            }
                                            .navigationViewStyle(.stack)
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                        } else if viewModel.imageData.isEmpty {
                            emptyStateView
                        }
                    }
                }
                .padding(.bottom, 5)
                .onAppear {
                    isLoading = true
                    let loadingStartTime = Date() // Record the start time
                    viewModel.fetchImages(email: globalContent.email) {
                        let elapsedTime = Date().timeIntervalSince(loadingStartTime)
                        let delay = max(0, 1.75 - elapsedTime) // Calculate remaining time to reach 1 second
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            isLoading = false
                            viewModel.updateRatingDataPoints(for: selectedRatingIndex)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var emptyStateView: some View {
        VStack {
            Text("You haven't scanned anything yet!")
                .font(.custom("inter-Bold", size: 18))
                .foregroundColor(.black)
                .padding(.bottom, 20)

            Image(systemName: "photo.on.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.black)
                .padding(.bottom, 20)

            Text("Once you scan something, it will appear here.")
                .font(.custom("inter-Regular", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

class HistoryViewModel: ObservableObject {
    @Published var imageData: [(image: UIImage, docID: String, ratings: [Int], timestamp: Timestamp)] = []
    @Published var ratingDataPoints: [RatingDataPoint] = []
    @Published var yAxisRange: ClosedRange<Double> = 0...10
    private let db = Firestore.firestore()

    private var ratingLabels: [String] {
        let selectedGender = UserDefaults.standard.string(forKey: "selectedGender") ?? "male"
        return selectedGender == "male" ? ["Overall", "Color", "Alignment", "Tooth/Surface Conditions", "Plaque Buildup", "Cavities", "Tooth Shape"] : ["Overall", "Color", "Alignment", "Tooth/Surface Conditions", "Plaque Buildup", "Cavities", "Tooth Shape"]
    }

    func fetchImages(email: String?, completion: @escaping () -> Void) {
        let userEmail = email ?? UserDefaults.standard.string(forKey: "email")

        guard let userEmail = userEmail else {
            print("No email found")
            completion()
            return
        }

        let userDoc = db.collection("userRatings").document(userEmail)
        let timestampsCollection = userDoc.collection("timestamps")

        timestampsCollection.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                completion()
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found.")
                self.imageData = []
                completion()
                return
            }

            var seenDocIDs: Set<String> = Set()
            var uniqueImages: [(image: UIImage, docID: String, ratings: [Int], timestamp: Timestamp)] = []

            DispatchQueue.main.async {
                documents.forEach { doc in
                    let docID = doc.documentID
                    if seenDocIDs.contains(docID) { return }
                    seenDocIDs.insert(docID)

                    guard let base64String = doc.data()["globalImage"] as? String,
                          let image = self.createImage(from: base64String),
                          let ratingArray = doc.data()["rating"] as? [Int],
                          let timestamp = doc.data()["timestamp"] as? Timestamp else {
                        return
                    }
                    uniqueImages.append((image: image, docID: docID, ratings: ratingArray, timestamp: timestamp))
                }
                self.imageData = uniqueImages
                completion()
            }
        }
    }

    func updateRatingDataPoints(for selectedRatingIndex: Int) {
        guard selectedRatingIndex >= 0 && selectedRatingIndex < ratingLabels.count else {
            print("Selected rating index out of bounds")
            return
        }

        if selectedRatingIndex == 0 {
            self.ratingDataPoints = imageData.map { item in
                let averageRating = Double(item.ratings.reduce(0, +)) / Double(item.ratings.count)
                return RatingDataPoint(date: item.timestamp.dateValue(), rating: averageRating)
            }.sorted(by: { $0.date < $1.date })
        } else {
            let ratingIndex = selectedRatingIndex - 1
            guard ratingIndex >= 0 else { return }

            self.ratingDataPoints = imageData.compactMap { item in
                guard ratingIndex < item.ratings.count else { return nil }
                return RatingDataPoint(date: item.timestamp.dateValue(), rating: Double(item.ratings[ratingIndex]))
            }.sorted(by: { $0.date < $1.date })
        }

        updateYAxisRange()
    }

    private func updateYAxisRange() {
        guard let minRating = ratingDataPoints.map({ $0.rating }).min(),
              let maxRating = ratingDataPoints.map({ $0.rating }).max() else {
            yAxisRange = 0...10
            return
        }

        let padding: Double = 5
        let lowerBound = max(floor((minRating - padding) / 10) * 10, 0)
        let upperBound = min(ceil((maxRating + padding) / 10) * 10, 100)

        yAxisRange = lowerBound...upperBound
    }

    private func createImage(from base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            print("Failed to decode Base64 string.")
            return nil
        }
        return UIImage(data: imageData)
    }
}

struct RatingDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let rating: Double
}
