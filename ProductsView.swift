
import SwiftUI
import FirebaseFirestore



let productList = [
    ["Tom's Naturally Clean Toothbrush", "Philips Sonicare 9900 Prestige", "CURAPROX, the Hydrosonic Pro", "Oral-B Pro1000", "Quip Sonic Electric Toothbrush", "Philips Sonicare ProtectiveClean 4100 Rechargeable Electric Toothbrush", "Oral-B 6000 SmartSeries Electric Toothbrush", "Philips Sonicare ProtectiveClean 5100"],
    ["Davids Sensitive+Whitening w/nano-Hydroxyapatite","CVS Health Gum & Enamel Repai","Crest Densify","Hello Antiplaque + Whitening Fluoride Free","Colgate Optic White Pro Series Toothpaste","Tom's of Maine Luminous White","Sensodyne Pronamel Toothpaste","Parodontax Complete Protection Toothpaste","Cocoshine Whitening Toothpaste"],
    ["Hello Naturally Healthy Antigingivit","Listerine Zero Alcohol Mouthwash","Crest Pro-Health Clinical Rinse","Dental Herb Company Tooth & Gums Tonic","Listerine Cool Mint Antiseptic Mouthwash","ACT Restoring Zero Alcohol Fluoride Mouthwash"],
    ["Tom's of Maine Naturally Waxed Antiplaque Flat Floss","Burst Floss","Cocofloss","Mintly Dental Floss"," Oral-B Glide Pro-Health Dental Floss", "DenTek Triple Clean Advanced Clean Floss"],
    ["Waterpik Sonic-Fusion 2.0","Philips Sonicare Cordless Power Flosser 3000", "Smile Brilliant CariPRO Water Flosser","Waterpik Cordless Water Flosser"],
    ["Snow The Tongue Cleanser","MasterMedi Tongue Scraper "],
    ["Crest 3DWhitestrips Professional Effects"]
    
]

struct ProductsView: View {
    @State private var workoutPlan: [Int] = []
    @State private var isLoading: Bool = true
    @State private var showInstructions: Bool = false
    @State private var showFullWeek: Bool = false
    @State private var predictedIncrease: Int = Int.random(in: 1...3)
    @State private var isAddedToMorning: [Bool] = [false, false, false, false, false, false, false]
    @State private var isAddedToMidday: [Bool] = [false, false, false, false, false, false, false]
    @State private var isAddedToEvening: [Bool] = [false, false, false, false, false, false, false]
    @State private var morningProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @State private var middayProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @State private var eveningProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @State private var hasSavedProducts: Bool = false;
    @EnvironmentObject var globalContent: GlobalContent

    let db = Firestore.firestore()
    let productIdentity = ["Toothbrush", "Toothpaste", "Mouthwash", "Floss", "WaterPick", "TongueScraper", "WhiteningStrip"]

    var todayIndex: Int {
        let today = Calendar.current.component(.weekday, from: Date()) - 2
        return today >= 0 ? today : 6
    }

    var body: some View {
        VStack {
                if workoutPlan.isEmpty {
                    Text("No product recommendations available. Take a Scan")
                        .font(.custom("inter-Bold", size: 20))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Title with Chalkboard SE font for a gamified look
                    Text("Products")
                        .font(.custom("inter-Bold", size: 28)) // Reduced font size from 36 to 28
                        .foregroundColor(.black)
                        .padding(.bottom, 4)

                    // Predicted increase section with bold text for emphasis
                    Text("Product Recommendations For You")
                        .font(.custom("inter-Regular", size: 16))
                        .foregroundColor(.gray)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(0..<workoutPlan.count, id: \.self) { index in
                                if(index < 7 && workoutPlan[index] < productList[index].count) {
                                    HStack(spacing: 4) {
                                        Image("\(productIdentity[index])\(workoutPlan[index]+1)")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 140, height: 230)
                                            .padding(.leading,20)
                                        Spacer()
                                        VStack{
                                            Text("\(productList[index][workoutPlan[index]])")
                                                .font(.custom("inter-Bold", size: 16))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                .padding(.trailing, 20)
                                            Text("Add Product to Routine")
                                                .font(.custom("Avenir-Black", size: 12))
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.center)
                                                .padding(.trailing, 20)
                                                .padding(.top, 20)
                                                .padding(.bottom, 7)
                                            HStack(spacing: 11) {
                                                Button(action: {
                                                    // Toggle the state when the button is clicked
                                                    isAddedToMorning[index].toggle()
                                                    if(isAddedToMorning[index] == true)
                                                    {
                                                        morningProducts[index] = workoutPlan[index]
                                                    }
                                                    else {
                                                        morningProducts[index] = -1
                                                    }
                                                    hasSavedProducts = false
                                                }) {
                                                    VStack {
                                                        // Change icon based on state
                                                        Image(systemName: isAddedToMorning[index] ? "plus.rectangle.fill" : "plus.rectangle")
                                                            .resizable()
                                                            .frame(width: 40, height: 30)
                                                            .foregroundColor(.gray)
                                                        
                                                        // Change text based on state
                                                        Text(isAddedToMorning[index] ? "Morning" : "Morning")
                                                            .font(.custom("inter-Regular", size: 10)) // You can adjust the font to match the style in your image
                                                            .foregroundColor(.gray)
                                                    }
                                                    .background(Color.white) // Background color
                                                    .cornerRadius(10)         // Rounded corners
                                                }
                                                Button(action: {
                                                    // Toggle the state when the button is clicked
                                                    isAddedToMidday[index].toggle()
                                                    if(isAddedToMidday[index] == true)
                                                    {
                                                        middayProducts[index] = workoutPlan[index]
                                                    }
                                                    else {
                                                        middayProducts[index] = -1
                                                    }
                                                    hasSavedProducts = false;
                                                }) {
                                                    VStack {
                                                        // Change icon based on state
                                                        Image(systemName: isAddedToMidday[index] ? "plus.rectangle.fill" : "plus.rectangle")
                                                            .resizable()
                                                            .frame(width: 40, height: 30)
                                                            .foregroundColor(.gray)
                                                        
                                                        // Change text based on state
                                                        Text(isAddedToMidday[index] ? "Midday" : "Midday")
                                                            .font(.custom("inter-Regular", size: 10)) // You can adjust the font to match the style in your image
                                                            .foregroundColor(.gray)
                                                    }
                                                    .background(Color.white) // Background color
                                                    .cornerRadius(10)         // Rounded corners
                                                }
                                                Button(action: {
                                                    // Toggle the state when the button is clicked
                                                    isAddedToEvening[index].toggle()
                                                    if(isAddedToEvening[index] == true)
                                                    {
                                                        eveningProducts[index] = workoutPlan[index]
                                                    }
                                                    else {
                                                        eveningProducts[index] = -1
                                                    }
                                                    hasSavedProducts = false
                                                }) {
                                                    VStack {
                                                        // Change icon based on state
                                                        Image(systemName: isAddedToEvening[index] ? "plus.rectangle.fill" : "plus.rectangle")
                                                            .resizable()
                                                            .frame(width: 40, height: 30)
                                                            .foregroundColor(.gray)
                                                        
                                                        // Change text based on state
                                                        Text(isAddedToEvening[index] ? "Evening" : "Evening")
                                                            .font(.custom("inter-Regular", size: 10)) // You can adjust the font to match the style in your image
                                                            .foregroundColor(.gray)
                                                    }
                                                    .background(Color.white) // Background color
                                                    .cornerRadius(10)         // Rounded corners
                                                }
                                            }
                                            .padding(.trailing, 20)
                                        }
                                        
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 300 )
                                    .background(Color.white)
                                    .clipped()
                                    .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    VStack{
                        Button(action: {
                            // Toggle the state when the button is clicked
                            if(hasSavedProducts == false) {
                                DispatchQueue.main.async {
                                    globalContent.morningProducts = self.morningProducts
                                    globalContent.middayProducts = self.middayProducts
                                    globalContent.eveningProducts = self.eveningProducts
                                    globalContent.saveProductList()
                                    hasSavedProducts = true
                                }
                            }
                            
                            
                        }) {
                            VStack {
                                // Change icon based on state
                                Text("Save Products to Routine")
                                    .font(.custom("inter-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .cornerRadius(30)
                                    .background(.black)
                                
                                // Change text based on state
                                Text("load indicated products to routine")
                                    .font(.custom("inter-Regular", size: 10)) // You can adjust the font to match the style in your image
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 4)
                                Text("Sources for product recommendations found in \"Scan\" tab (Citations)")
                                    .font(.custom("inter-Regular", size: 10))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(Color.white) // Background color
                            .cornerRadius(10)         // Rounded corners
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 70)
                    
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadWorkoutPlan()
        }
        .navigationBarTitle("Products", displayMode: .inline)
        .padding()
    }


    private func loadWorkoutPlan() {
        if let data = UserDefaults.standard.data(forKey: "savedWorkoutPlan") {
            let decoder = JSONDecoder()
            if let savedPlan = try? decoder.decode([Int].self, from: data) {
                let isValid = savedPlan.allSatisfy { $0 >= 0 && $0 < 10}
                if isValid && savedPlan.count == 7 {
                    print(savedPlan)
                    workoutPlan = savedPlan
                } else {
                    isLoading = false
                }
            } else {
                isLoading = false
            }
        } else {
            isLoading = false
        }
    }

}




#Preview {
    ProductsView()
}
