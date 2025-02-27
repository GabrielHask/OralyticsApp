//
//  PhysiqueScan2View.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI

struct PhysiqueScan2View: View {
    // State properties for animations
    @State private var showOverall = false
    @State private var showChest = false
    @State private var showArms = false
    @State private var showAbs = false
    @State private var showPotential = false
    @Environment(\.presentationMode) var presentationMode
    func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            Spacer()
            ZStack {
                Image("BodyImage")
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.5) // Adjusts the image height to be proportionate
                    .clipped()

                // Rectangular Score Boxes with Animations
                // Using different positions for each score
                Group {
                    // Overall Score - Top Left
                    Text("Overall: 91")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showOverall ? 1 : 0)
                        .offset(x: -100, y: -150) // Top left position
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                                showOverall = true
                            }
                        }
                    
                    // Chest Score - Center Right
                    Text("Color: 92")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showChest ? 1 : 0)
                        .offset(x: 80, y: -50) // Center right position
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                                showChest = true
                            }
                        }
                    
                    // Arms Score - Bottom Left
                    Text("Gums: 88")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showArms ? 1 : 0)
                        .offset(x: -80, y: 100) // Bottom left position
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                                showArms = true
                            }
                        }
                    
                    // Abs Score - Center Left
                    Text("Symmetry: 91")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showAbs ? 1 : 0)
                        .offset(x: -80, y: 30) // Center left position
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                                showAbs = true
                            }
                        }
                    
                    // Potential Score - Bottom Right
                    Text("Health: 96")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showPotential ? 1 : 0)
                        .offset(x: 100, y: 150) // Bottom right position
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                                showPotential = true
                            }
                        }
                }
            }

            // Text Section
            VStack(spacing: 16) {
                Text("AI Teeth Analysis and Dental Assistant")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We use AI to improve your dental aesthetic and oral health.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)

            Spacer()

            // Next Button
            Button(action: {
                // Action for Next button
            }) {
                NavigationLink(destination: PhysiqueScan3View().navigationBarBackButtonHidden(true)) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                        .padding(.horizontal, 32)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    generateHapticFeedback()
                })
                .padding(.bottom, 40)
            }
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct PhysiqueScan2View_Previews: PreviewProvider {
    static var previews: some View {
        PhysiqueScan2View()
    }
}
