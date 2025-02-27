import SwiftUI
import UIKit

struct GlobalContentView: View {
    let globalImage: UIImage?
    let overallRating: Int
    let percentile: Double // Represents how the user's rating compares to others

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 30) {
                // Global Image (Circular)
                if let globalImage = globalImage {
                    Image(uiImage: globalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 4))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.top, 20)
                }

                // Overall Rating Section
                VStack(spacing: 8) {
                    Text("Overall Rating")
                        .font(.custom("Chalkboard SE", size: 24))
                        .foregroundColor(.black)
                    Text("\(overallRating)")
                        .font(.custom("Chalkboard SE", size: 48))
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                )
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                // Percentage Text
                Text("Great Work")
                    .font(.custom("Chalkboard SE", size: 18))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()

                // Normal Distribution Curve with Indicator and Label
                NormalDistributionView(percentile: percentile)
                    .frame(height: 150)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, 20)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

// Custom View for Normal Distribution Curve
struct NormalDistributionView: View {
    let percentile: Double // Value between 0 and 1

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw the normal distribution curve using a smooth Bezier path
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midY = height * 0.8

                    // Parameters for the bell curve
                    let amplitude: CGFloat = height * 0.6

                    path.move(to: CGPoint(x: 0, y: midY))

                    // Create a smooth bell curve using Gaussian function
                    for x in stride(from: 0, through: width, by: 1) {
                        let relativeX = x / width
                        let exponent = -pow((relativeX - 0.5) * 4, 2)
                        let y = midY - amplitude * CGFloat(exp(exponent))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    path.addLine(to: CGPoint(x: width, y: midY))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let midY = height * 0.8
                        let amplitude: CGFloat = height * 0.6

                        path.move(to: CGPoint(x: 0, y: midY))

                        for x in stride(from: 0, through: width, by: 1) {
                            let relativeX = x / width
                            let exponent = -pow((relativeX - 0.5) * 4, 2)
                            let y = midY - amplitude * CGFloat(exp(exponent))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.black, lineWidth: 2)
                )

                // Indicator Marker
                let xPosition = CGFloat(percentile) * geometry.size.width
                let markerSize: CGFloat = 14

                VStack(spacing: 6) {
                    // Marker (Sleek Arrow)
                    InvertedTriangle()
                        .fill(Color.green)
                        .frame(width: markerSize, height: markerSize)
                        .shadow(color: Color.orange.opacity(0.5), radius: 4, x: 0, y: 2)

                    // Label
                    Text("You're here")
                        .font(.custom("Chalkboard SE", size: 12))
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.7))
                        )
                        .padding(.top, 4)
                }
                .position(x: xPosition, y: geometry.size.height - 15)
            }
        }
    }
}

// Custom Triangle Shape for Indicator
struct InvertedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

struct GlobalContentView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalContentView(globalImage: UIImage(systemName: "person.circle.fill"),
                          overallRating: 86,
                          percentile: 0.81)
            .previewDevice("iPhone 14")
    }
}

