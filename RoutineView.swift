//
//  RoutineView.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/18/24.
//

import SwiftUI
import FirebaseFirestore

struct RoutineView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @EnvironmentObject var globalContent: GlobalContent
    let productIdentity = ["Toothbrush", "Toothpaste", "Mouthwash", "Floss", "WaterPick", "TongueScraper", "WhiteningStrip"]

    var body: some View {
        VStack{
            Text("Routine")
                .font(.custom("inter-Bold", size: 28)) // Reduced font size from 36 to 28
                .foregroundColor(.black)
                .padding(.bottom, 4)

            // Predicted increase section with bold text for emphasis
            Text("Add Products To Routine")
                .font(.custom("inter-Regular", size: 16))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Morning")
                        .font(.custom("inter-Bold", size: 20))
                        .foregroundColor(.black)
                    VStack{
                        if(!viewModel.mProducts.isEmpty)
                        {
                            ForEach(0..<viewModel.mProducts.count, id: \.self) { index in
                            if(viewModel.mProducts[index] != -1) {
                                HStack (spacing: 12){
                                    Image("\(productIdentity[index])\(viewModel.mProducts[index]+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 45)
                                    Text("\(productList[index][viewModel.mProducts[index]])")
                                        .font(.custom("inter-Bold", size: 16))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.trailing, 20)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                                .background(Color.white)
                                .clipped()
                                .shadow(radius: 3)
                                .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Text("Midday")
                        .font(.custom("inter-Bold", size: 20))
                        .foregroundColor(.black)
                    VStack{
                        if(!viewModel.mdProducts.isEmpty)
                        {
                            ForEach(0..<viewModel.mdProducts.count, id: \.self) { index in
                                if(viewModel.mdProducts[index] != -1) {
                                    HStack (spacing: 12){
                                        Image("\(productIdentity[index])\(viewModel.mdProducts[index]+1)")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 45)
                                        Text("\(productList[index][viewModel.mdProducts[index]])")
                                            .font(.custom("inter-Bold", size: 16))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.trailing, 20)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                                    .background(Color.white)
                                    .clipped()
                                    .shadow(radius: 3)
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)

                    Text("Evening")
                        .font(.custom("inter-Bold", size: 20))
                        .foregroundColor(.black)
                    VStack{
                        if(!viewModel.eProducts.isEmpty)
                        {
                            ForEach(0..<viewModel.eProducts.count, id: \.self) { index in
                                if(viewModel.eProducts[index] != -1) {
                                    HStack (spacing: 12){
                                        Image("\(productIdentity[index])\(viewModel.eProducts[index]+1)")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 45)
                                        Text("\(productList[index][viewModel.eProducts[index]])")
                                            .font(.custom("inter-Bold", size: 16))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.trailing, 20)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                                    .background(Color.white)
                                    .clipped()
                                    .shadow(radius: 3)
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)

                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.fetchProducts(email: globalContent.email)
        }
        .navigationBarTitle("Routine", displayMode: .inline)
        .padding()
    }
}

class RoutineViewModel: ObservableObject {
    @Published var mProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @Published var mdProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @Published var eProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    private let db = Firestore.firestore()

    func fetchProducts(email: String?) {
        let userEmail = email ?? UserDefaults.standard.string(forKey: "email")

        guard let userEmail = userEmail else {
            print("No email found")
            return
        }

        let userDoc = db.collection("productList").document(userEmail)
        let timestampsCollection = userDoc.collection("timestamps")

        timestampsCollection.order(by: "timestamp", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            DispatchQueue.main.async {
                for document in querySnapshot!.documents {
                    guard let morningProducts = document.data()["morningProducts"] as? [Int],
                          let middayProducts = document.data()["middayProducts"] as? [Int],
                          let eveningProducts = document.data()["eveningProducts"] as? [Int],
                          let timestamp = document.data()["timestamp"] as? Timestamp else {
                        return
                }
                    self.mProducts = morningProducts
                    self.mdProducts = middayProducts
                    self.eProducts = eveningProducts
            }

            }

        }
    }
}

#Preview {
    RoutineView()
}
