import SwiftUI

struct RatingDistributionView: View {
    var image: UIImage  // User's profile image
    var overallRating: Int  // User's overall rating
    @State private var currentPage = 0  // To track which page is active
    @State private var navigateToNextPage = false  // State to control navigation

    var body: some View {
        VStack(spacing: 20) {
            // Circular Image
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)  // Circle Image Size
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional border
                .shadow(radius: 10)
                .padding(.top, 40)  // Padding from the top

            // Overall Rating Text
            Text("Overall")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.white)

            // Rating Score
            Text("\(overallRating)")
                .font(.system(size: 80, weight: .bold))  // Large bold rating score
                .foregroundColor(.white)

            // Normal Distribution Graph with Indicator
            NormalDistributionGraph(overallRating: overallRating)
                .padding(.horizontal, 30)  // Add padding for the graph to fit well

            // "Your overall is better than" text
            Text("Your overall is better than \(overallRating)% of people")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 10)

            // Save and Share Buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Save action
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                Button(action: {
                    // Share action
                }) {
                    Label("Share", systemImage: "paperplane")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 20)  // Padding for spacing from the graph

            // NEXT Button
            Button(action: {
                navigateToNextPage = true
            }) {
                Text("NEXT")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()  // Push content to the top

            // Page indicator dots
            HStack(spacing: 8) {
                Circle()
                    .fill(currentPage == 0 ? Color.white : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(currentPage == 1 ? Color.white : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))  // Set the background color
        .navigationBarHidden(true) // Hide navigation bar if needed
        .navigationBarBackButtonHidden(true)
        // Adjusted gesture to detect right swipe
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {  // Swipe right detected
                        navigateToNextPage = true
                    }
                }
        )

    }
}

// Normal Distribution Graph View
struct NormalDistributionGraph: View {
    var overallRating: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Normal Distribution Curve Shape
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    path.move(to: CGPoint(x: 0, y: height))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height),
                        control: CGPoint(x: width / 2, y: 0)
                    )
                }
                .stroke(Color.white, lineWidth: 2)  // Curve stroke

                // "You are here" triangle pointer
                Triangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: calculateIndicatorPosition(geometry: geometry) - 10, y: -20)

                // Fill the graph up to the user's rating
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    path.move(to: CGPoint(x: 0, y: height))
                    path.addQuadCurve(
                        to: CGPoint(x: calculateIndicatorPosition(geometry: geometry), y: height),
                        control: CGPoint(x: calculateIndicatorPosition(geometry: geometry) / 2, y: height - calculateIndicatorPosition(geometry: geometry) / (width / height))
                    )
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
            }
        }
        .frame(height: 120)  // Set graph height
    }

    // Function to calculate the position of "You are here" based on the rating
    func calculateIndicatorPosition(geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width
        let relativePosition = CGFloat(overallRating) / 100.0
        return width * relativePosition
    }
}

// Triangle Shape for the indicator
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Preview
struct RatingDistributionView_Previews: PreviewProvider {
    static var previews: some View {
        RatingDistributionView(image: UIImage(), overallRating: 86)
    }
}
