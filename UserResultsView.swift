import UIKit
import SwiftUI

extension UIView {
    func captureScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

struct NextButton: View {
    var body: some View {
        Text("Next")
            .font(.custom("ChalkboardSE-Bold", size: 17))
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
    }
}

struct SnapshotViewController: UIViewControllerRepresentable {
    var view: UIView
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view = view
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct UserResultsView: View {
    @EnvironmentObject var globalContent: GlobalContent
    @State private var capturedImage: UIImage? = nil

    var ratings: [Int] {
        globalContent.content
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    CircleImage()
                        .padding(.top, 20)

                    if ratings.isEmpty {
                        EmptyRatingsView()
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            OverallRatingView(overallRating: calculateOverall(ratings))
                            RatingsListView(ratings: ratings, labels: ratingLabels)
                        }
                        .padding()
                    }

                    NavigationLink(destination: HistoryView()) {
                        HStack {
                            Text("View your scans")
                                .font(.custom("ChalkboardSE-Regular", size: 17))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    ShareButton(capturedImage: $capturedImage)
                        .padding(.top, 0)
                    
                    NextButton()
                        .padding(.top, 10)
                }
                .font(.custom("ChalkboardSE-Regular", size: 16))
                .background(Color.white.edgesIgnoringSafeArea(.all))
                .onAppear {
                    DispatchQueue.main.async {
                        captureScreenshot()
                    }
                    // Customize navigation bar title font
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.titleTextAttributes = [
                        .font: UIFont(name: "ChalkboardSE-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
                    ]
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            .navigationTitle("User Results")
        }
    }
    
    func calculateOverall(_ ratings: [Int]) -> Int {
        guard !ratings.isEmpty else { return 0 }
        return ratings.reduce(0, +) / ratings.count
    }

    private var ratingLabels: [String] {
        ["Color", "Plaque Buildup", "Alignment", "Decay", "Teeth Condition", "Symmetry"]
    }

    func captureScreenshot() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let rootView = window.rootViewController?.view {
            self.capturedImage = rootView.captureScreenshot()
        }
    }
}

struct OverallRatingView: View {
    var overallRating: Int
    
    var body: some View {
        VStack {
            Text("\(overallRating)")
                .font(.custom("ChalkboardSE-Bold", size: 45))
                .foregroundColor(.black)
            
            Text(" Overall ")
                .font(.custom("ChalkboardSE-Regular", size: 24))
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct RatingsListView: View {
    var ratings: [Int]
    var labels: [String]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(0..<min(3, ratings.count), id: \.self) { index in
                    RatingItem(label: labels[index], score: ratings[index])
                }
            }
            .padding(.leading, 10)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(3..<ratings.count, id: \.self) { index in
                    RatingItem(label: labels[index], score: ratings[index])
                }
            }
            .padding(.leading, 10)
        }
        .padding(.bottom, 20)
    }
}

struct RatingItem: View {
    var label: String
    var score: Int
    
    @State private var progressValue: Double = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .font(.custom("ChalkboardSE-Regular", size: 17))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(score)")
                    .font(.custom("ChalkboardSE-Bold", size: 25))
                    .foregroundColor(.black)
            }
            
            RatingProgressBar(value: $progressValue, maxValue: 100)
                .frame(height: 10)
                .padding(.top, 5)
                .onAppear {
                    progressValue = Double(score)
                }
        }
        .padding(.horizontal)
    }
}

struct RatingProgressBar: View {
    @Binding var value: Double
    var maxValue: Double
    
    var body: some View {
        let progressWidth = CGFloat(value / maxValue) * (UIScreen.main.bounds.width / 2 - 40)
        let progressColor: Color
        
        if value <= 40 {
            progressColor = Color.red
        } else if value <= 75 {
            progressColor = Color.orange
        } else {
            progressColor = Color.green
        }
        
        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 10)
            
            RoundedRectangle(cornerRadius: 5)
                .fill(progressColor)
                .frame(width: progressWidth, height: 10)
        }
        .animation(nil, value: progressWidth)
    }
}

struct CircleImage: View {
    @EnvironmentObject var globalContent: GlobalContent

    var body: some View {
        if let imageData = globalContent.globalImage,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.black, lineWidth: 3)
                }
                .shadow(radius: 5)
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.black, lineWidth: 3)
                }
                .shadow(radius: 5)
        }
    }
}

struct ShareButton: View {
    @Binding var capturedImage: UIImage?

    var body: some View {
        Button(action: shareButtonTapped) {
            Text("Share Results")
                .font(.custom("ChalkboardSE-Bold", size: 17))
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
    }
    
    private func shareButtonTapped() {
        let textToShare = "Check out my results from Oralytics the new dental app! Download the app on the appstore"
        
        var itemsToShare: [Any] = [textToShare]
        
        if let image = capturedImage {
            itemsToShare.append(image)
        }
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct EmptyRatingsView: View {
    var body: some View {
        VStack {
            Text("No ratings available")
                .font(.custom("ChalkboardSE-Regular", size: 28))
                .foregroundColor(.gray)
                .padding()
        }
    }
}

struct UserResultsView_Previews: PreviewProvider {
    static var previews: some View {
        UserResultsView()
            .environmentObject(GlobalContent())
    }
}
