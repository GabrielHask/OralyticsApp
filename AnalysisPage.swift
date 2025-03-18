//
//  AnalysisPage.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI
import Foundation
import SuperwallKit
func parseMatrix(from matrixString: String) -> [[Int]]? {
        // Remove outer brackets and any extra spaces
        // Step 1: Split the string into rows
        
        let trimmedString = matrixString.trimmingCharacters(in: .whitespacesAndNewlines)
        let rows = trimmedString.split(separator: "\n")
        // Step 2: Convert each row into an array of integers
        let array2D = rows.map { row -> [Int] in
                return row.split(separator: ", ").compactMap { Int($0) }
        }
        return array2D
        
}
func checkSubscription(customerId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "disabled_url") else {
                completion(false)
                print("could not connect to backend maybe an issue")
                return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["customerId": customerId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                        print("Error: \(error)")
                        completion(false)
                        return
                }
                guard let data = data else {
                        completion(false)
                        return
                }
                do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] {
                                // Extract hasActiveSubscription from the JSON response
                                if let hasActiveSubscription = json["hasActiveSubscription"] {
                                        completion(hasActiveSubscription)
                                } else {
                                        completion(false)
                                }
                        }
                } catch {
                        print("JSON Error: \(error)")
                        completion(false)
                }
        }
        task.resume()
}



import SwiftUI
// Define a custom error type
enum AnalyzeImageError: Error {
        case lightingIssue
        case imageAnalysisFailed(Error)
        case textAnalysisFailed(Error)
        case workoutPlanGenerationFailed
        case encodingError
        case requestError(Error)
        case noData
        case jsonParsingError(Error)
        case maxRetriesReached
}
func saveWorkoutToUserDefaults(workout: [Int], key: String) {
        let encoder = JSONEncoder()
        do {
                let data = try encoder.encode(workout)
                UserDefaults.standard.set(data, forKey: key)
        } catch {
                print("Failed to encode routine: \(error)")
        }
}


func parseWorkoutArray(from workoutString: String) -> [Int]? {
        // Remove brackets and split the string by commas
        let trimmedString = workoutString.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let workoutComponents = trimmedString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Convert each component to Int
        let workoutArray = workoutComponents.compactMap { Int($0) }
        
        // Ensure the array has exactly 7 integers
        return workoutArray.count == 7 ? workoutArray : nil
}


func processImageAndText(image: UIImage, globalContent: GlobalContent, completion: @escaping (Result<String, AnalyzeImageError>) -> Void) {
        // Introduce a flag to ensure saveRatings() is called only once
        var hasSavedRatings = false
        func analyzeAndGenerateWorkout(image: UIImage, retryCount: Int = 0, maxRetries: Int = 7, completion: @escaping (Result<String, AnalyzeImageError>) -> Void) {
                guard retryCount < maxRetries else {
                    if !hasSavedRatings {
                        DispatchQueue.main.async {
                            globalContent.content = [0,0,0,0,0,0,0]
                            globalContent.savedContent = [0,0,0,0,0,0,0]
                            globalContent.ratings2 = [0,0,0,0] // Store the additional values
                            globalContent.saveRatings()
                            globalContent.addToLeaderboard()
                            hasSavedRatings = true
                        }// Set the flag to true after saving ratings
                    
                    }
                    let workoutPlanString2 = "[0,0,0,0,0,0,0]"
                    let workoutPlan2 = workoutPlanString2
                            .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                            .split(separator: ",")
                            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    
                    if workoutPlan2.count == 7 {
                            print("Workout Plan saved to defaults: \(workoutPlan2)")
                            saveWorkoutToUserDefaults(workout: workoutPlan2, key: "savedWorkoutPlan")
                            completion(.success(workoutPlanString2))
                    }
                    completion(.success(workoutPlanString2))
                    return
                }
                
                // Step 1: Analyze the image
                analyzeImage(image: image) { imageResult in
                        switch imageResult {
                        case .success(let (content, additionalContent)):
                                
                                let values = content
                                        .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                                        .components(separatedBy: ",")
                                        .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                                let additionalValues = additionalContent
                                        .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                                        .components(separatedBy: ",")
                                        .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                                
                                if values.count == 7 && additionalValues.count == 4 {
                                    // Update globalContent with the analyzed data only once
                                    if !hasSavedRatings {
                                        DispatchQueue.main.async {
                                            globalContent.content = values
                                            globalContent.savedContent = values
                                            globalContent.ratings2 = additionalValues // Store the additional values
                                            globalContent.saveRatings()
                                            globalContent.addToLeaderboard()
                                            hasSavedRatings = true
                                        }// Set the flag to true after saving ratings
                                    
                                    }
                                    generateWorkoutPlan(basedOn: content, selectedDays: globalContent.selectedDays) { workoutResult in
                                        switch workoutResult {
                                            case .success(let workoutPlanString):
                                            // Parse the workout plan string to a 1D array of length 7
                                            let workoutPlan = workoutPlanString
                                                    .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                                                    .split(separator: ",")
                                                    .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                                            
                                            if workoutPlan.count == 7 {
                                                    print("Workout Plan saved to defaults: \(workoutPlan)")
                                                    saveWorkoutToUserDefaults(workout: workoutPlan, key: "savedWorkoutPlan")
                                                    completion(.success(workoutPlanString))
                                            }
                                            else {
                                                // Retry if the workout array length is incorrect
                                                    analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
                                            }
                                            
                                            case .failure:
                                            // Retry if workout generation fails
                                                analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
                                        }
                                    }
                                } else {
                                        // Retry if content analysis results are invalid
                                    analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
                                }
                            
                            case .failure(let error):
                            // Retry if image analysis fails
                                analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
                        }
                }
        }
    
    // Start the process of analyzing the image and generating the workout
    analyzeAndGenerateWorkout(image: image, completion: completion)
}

//    generateWorkoutPlan(basedOn: content, selectedDays: globalContent.selectedDays) { workoutResult in
//                                                switch workoutResult {
//                                                case .success(let workoutPlanString):
//                                                        // Parse the workout plan string to a 1D array of length 7
//                                                        let workoutPlan = workoutPlanString
//                                                                .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
//                                                                .split(separator: ",")
//                                                                .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
//
//                                                        if workoutPlan.count == 7 {
//                                                                print("Workout Plan saved to defaults: \(workoutPlan)")
//                                                                saveWorkoutToUserDefaults(workout: workoutPlan, key: "savedWorkoutPlan")
//                                                                completion(.success(workoutPlanString))
//                                                            }
//
    //else {
//                                                                // Retry if the workout array length is incorrect
//                                                                analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
//                                                        }
//
//                                                case .failure:
//                                                        // Retry if workout generation fails
//                                                        analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
//                                                }
//                                        }
//                                } else {
//                                        // Retry if content analysis results are invalid
//                                        analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)
//                                }
//
//                        case .failure(let error):
//                                // Retry if image analysis fails
//                                analyzeAndGenerateWorkout(image: image, retryCount: retryCount + 1, completion: completion)








extension Notification.Name {
        static let analysisComplete = Notification.Name("analysisComplete")
}

struct AnalysisPage: View {
        @State var selectedImage: UIImage
        @State private var content: String = ""
        @State private var showAlert = false
        @State private var alertMessage = ""
        @State private var navigateToTabBar = false
        @State private var navigateToPayment = false
        @State private var isLoading = false
        @State private var workoutPlan: String = ""
        @State private var resetUploadPicture: Bool = false
        @State private var currentCaptionIndex = 0
        @State private var selectedTab = 1
        @State private var navigateToHistory = false
        
        @EnvironmentObject var globalContent: GlobalContent
        
        @State private var rotationAngle: Double = 0
        @State private var textOpacity: Double = 0
        
        @State private var savedAmount: Double = 1762
        @State private var caloriesSaved: Double = 82565
        @State private var remCyclesAdded: Double = 1265
        
        private let targetSavedAmount: Double = 1560
        private let targetCaloriesSaved: Double = 55692
        private let targetRemCyclesAdded: Double = 1825
        
        var body: some View {
                VStack {
                        if isLoading {
                                ZStack {
                                        Color.white
                                                .edgesIgnoringSafeArea(.all)
                                        customProgressView()
                                }
                        } else {
                                Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .padding()
                        }
                        // Navigation links
                        NavigationLink(
                                destination: TabBarView(selectedTab: $selectedTab)
                                        .navigationBarHidden(true),
                                isActive: $navigateToTabBar
                        ) {
                                EmptyView()
                        }
                        NavigationLink(
                                destination: PaymentView(globalImage: selectedImage)
                                        .navigationBarHidden(true),
                                isActive: $navigateToPayment
                        ) {
                                EmptyView()
                        }
                }
                .navigationViewStyle(.stack)
                .navigationTitle("Analysis Page")
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                        isLoading = true
                        processImageAndText(image: selectedImage, globalContent: globalContent) { result in
                                isLoading = false
                                print("\(isLoading)")
                                switch result {
                                case .success(_):
                                        Task {
                                            do {
                                                    let result = await Superwall.shared.getPresentationResult(forEvent: "tab_trigger")
                                                    print("tab trigger")
                                                    switch result {
                                                    case .userIsSubscribed, .holdout, .eventNotFound, .noRuleMatch, .paywallNotAvailable:
                                                            DispatchQueue.main.async {
                                                                    self.navigateToTabBar = true
                                                            }
                                                    case .paywall:
                                                            DispatchQueue.main.async {
                                                                    self.navigateToPayment = true
                                                            }
                                                    }
                                            } catch {
                                                    DispatchQueue.main.async {
                                                            self.navigateToPayment = true
                                                    }
                                            }
//                                            let result = await Superwall.shared.getPresentationResult(forEvent: "campaign_trigger")
//                                            print("campaign trigger")
//                                            switch result {
//                                            case .userIsSubscribed, .holdout, .eventNotFound, .noRuleMatch, .paywallNotAvailable:
//                                                DispatchQueue.main.async {
//                                                    self.navigateToTabBar = true
//                                                }
//                                            case .paywall:
//                                                DispatchQueue.main.async {
//                                                    self.navigateToTabBar = true
//                                                }
//                                            }

                                        }
                                case .failure(let error):
                                        DispatchQueue.main.async {
                                                self.alertMessage = "Error analyzing image: \(error)"
                                                self.showAlert = true
                                                self.navigateToTabBar = true;
                                        }
                                }
                        }
                }
                .onReceive(globalContent.$navigateToTabBar) { value in
                        if value {
                                selectedTab = 1
                        }
                }
                .alert(isPresented: $showAlert) {
                        Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
        
                
                struct customProgressView: View { // Renamed to follow Swift conventions
                        // MARK: - State Variables
                        @State private var textOpacity: Double = 0.0
                        @State private var rotationAngle: Double = 0.0
                        @State private var savedAmount: Double = 1762
                        @State private var caloriesSaved: Double = 82565
                        @State private var remCyclesAdded: Double = 1265
                        
                        // Target values for animations
                        private let targetSavedAmount: Double = 300
                        private let targetCaloriesSaved: Double = 82565
                        private let targetRemCyclesAdded: Double = 1265
                        
                        // Status messages to display under the spinner
                        private let statusMessages = [
                                "Analyzing teeth aesthetic...",
                                "Creating personalized recommendations...",
                                "Setting up product recommendations...",
                                "Optimizing your dental routines...",
                                "Finalizing your dental analysis..."
                        ]
                        
                        @State private var currentStatusIndex: Int = 0
                        @State private var statusOpacity: Double = 1.0 // Initially visible
                        
                        // Timer to cycle through status messages
                        private let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
                        
                        var body: some View {
                                VStack(spacing: 30) {
                                        // Main status message at the top
                                        Text(statusMessages[currentStatusIndex])
                                                .font(.custom("Chalkboard SE", size: 18))
                                                .fontWeight(.heavy)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                .padding(.top, 50)
                                                .padding(.horizontal, 40)
                                                .opacity(statusOpacity)
                                                .animation(.easeInOut(duration: 0.5), value: statusOpacity)
                                        
                                        // Custom loading spinner
                                        ZStack {
                                                Circle()
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                                                        .frame(width: 110, height: 110)
                                                
                                                Circle()
                                                        .trim(from: 0, to: 0.7)
                                                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                                        .foregroundColor(.black)
                                                        .rotationEffect(.degrees(rotationAngle))
                                                        .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: rotationAngle)
                                        }
                                        .frame(width: 110, height: 110)
                                        .onAppear {
                                                startNumberAnimations()
                                                rotateSpinner()
                                        }
                                        
                                        // Status message under the spinner
                                        Text("1 year from now")
                                                .font(.custom("Chalkboard SE", size: 20))
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 40)
                                                .opacity(textOpacity)
                                                .animation(.easeIn(duration: 1.0), value: textOpacity)
                                        
                                        VStack(spacing: 30) {
                                                // First metric
//                                                VStack {
//                                                        Text("$\(Int(savedAmount))")
//                                                                .font(.custom("Chalkboard SE", size: 48))
//                                                                .fontWeight(.heavy)
//                                                                .foregroundColor(.black)
//                                                        Text("SAVED IN DENTAL FEES")
//                                                                .font(.custom("Chalkboard SE", size: 22))
//                                                                .fontWeight(.semibold)
//                                                                .foregroundColor(.gray)
//                                                }
                                                
                                                // Second metric
                                                VStack {
                                                        Text(" ")
                                                                .font(.custom("Chalkboard SE", size: 48))
                                                                .fontWeight(.heavy)
                                                                .foregroundColor(.black)
                                                        Text("HEALTH GAINED")
                                                                .font(.custom("Chalkboard SE", size: 22))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(.gray)
                                                }
                                                
                                                // Third metric
                                                VStack {

                                                        Text("CONFIDENCE GAINED")
                                                                .font(.custom("Chalkboard SE", size: 22))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(.gray)
                                                }
                                        }
                                        .opacity(textOpacity)
                                        .animation(.easeIn(duration: 1.0).delay(0.5), value: textOpacity)
                                        
                                        // Emphasized promise statement
                                        Text("Achieve results fast.")
                                                .font(.custom("Chalkboard SE", size: 22))
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                .padding(.top, 20)
                                                .padding(.horizontal, 40)
                                                .opacity(textOpacity)
                                                .animation(.easeIn(duration: 1.0).delay(1.0), value: textOpacity)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.white)
                                .edgesIgnoringSafeArea(.all)
                                .onReceive(timer) { _ in
                                        // Fade out the current message
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                                statusOpacity = 0.0
                                        }
                                        // Update the message and fade in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                currentStatusIndex = (currentStatusIndex + 1) % statusMessages.count
                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                        statusOpacity = 1.0
                                                }
                                        }
                                }
                                .onAppear {
                                        // Immediately show the first status message
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                                statusOpacity = 1.0
                                        }
                                }
                                .onDisappear {
                                        timer.upstream.connect().cancel()
                                }
                        }
                        
                        private func rotateSpinner() {
                                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                }
                        }
                        
                        private func startNumberAnimations() {
                                withAnimation(Animation.linear(duration: 2.0)) {
                                        self.savedAmount = self.targetSavedAmount
                                }
                                withAnimation(Animation.linear(duration: 2.0).delay(0.5)) {
                                        self.caloriesSaved = self.targetCaloriesSaved
                                }
                                withAnimation(Animation.linear(duration: 2.0).delay(1.0)) {
                                        self.remCyclesAdded = self.targetRemCyclesAdded
                                }
                                withAnimation(Animation.easeIn(duration: 1.0)) {
                                        self.textOpacity = 1.0
                                }
                        }
                }
        
}

func encodeImage(image: UIImage, targetSize: CGSize = CGSize(width: 256, height: 256), compressionQuality: CGFloat = 0.3) -> String? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        return imageData.base64EncodedString(options: .lineLength76Characters)
}
func analyzeImage(image: UIImage, completion: @escaping (Result<(String, String), AnalyzeImageError>) -> Void) {
        print("Analyzing started...")
        
        // Retrieve the selected gender from UserDefaults
        let selectedGender = UserDefaults.standard.string(forKey: "selectedGender") ?? "male" // Default to male
        print(selectedGender)
        
        guard let base64Image = encodeImage(image: image, compressionQuality: 0.3) else {
                completion(.failure(.encodingError))
                print("Failed to encode image")
                return
        }
        let url = URL(string: "disabled_url")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer disabled_key", forHTTPHeaderField: "Authorization")
        
        // Prepare different prompt messages for male and female
        let promptMessages: [[String: Any]]
        
        if selectedGender == "male" {
                promptMessages = [
                        [
                                "role": "user",
                                "content": [
                                        "This is an AI-image generated dental image of a man's teeth and lets pretend you are a dental expert and advisor. Provide an assessment from 0-100 of the quality of the following aspects of the man's dental health: overall smile aesthetic (look for teeth color and the beauty of their mouth and teeth), how white his teeth are (look at natural enamel shade, intrinsic discoloration, and surface stains), alignment and spacing (look how straight and evenly spaced the teeth are, the alignment of the dental arch, and the existence of crowding and gaps), tooth and surface conditions (examine the enamel surface for cracks, chips, or erosion, and signs of wear from grinding or acid erosion that would lower the score), plaque and tartar buildup (decrease score if there are visual signs of plaque deposits or hardened tartar on teeth such as yellow or brown buildup, particularly along the gum line), presence of cavities or decay (give lower points for presence of cavities or decay), and tooth shape and symmetry. Make it so people can get over 90 and not too many people get below 30. Grade from an aesthetics and health scale and make sure to give teeth that appear mostly perfectly white, symmetric, straight, and with little decay for both the teeth and gums a high score above 90. Put the assessment numbers in a Python list format separated by commas in the same line with the respective assessments in order separated by commas. Don't add a new line after the comma and do not include any description. Do not include the aspect name or anything else but the list. Example Output: [#, #, #, #, #, #, #]",
                                        ["image": base64Image, "resize": 768]
                                ]
                        ]
                ]
        } else {
                // Prompt for female assessment
                promptMessages = [
                        [
                                "role": "user",
                                "content": [
                                    "This is an AI-image generated dental image of a woman's teeth and lets pretend you are a dental expert and advisor. Provide an assessment from 0-100 of the quality of the following aspects of the woman's dental health: overall smile aesthetic (look for teeth color and the beauty of their mouth and teeth), how white her teeth are (look at natural enamel shade, intrinsic discoloration, and surface stains), alignment and spacing (look how straight and evenly spaced the teeth are, the alignment of the dental arch, and the existence of crowding and gaps), tooth and surface conditions (examine the enamel surface for cracks, chips, or erosion, and signs of wear from grinding or acid erosion that would lower the score), plaque and tartar buildup (decrease score if there are visual signs of plaque deposits or hardened tartar on teeth such as yellow or brown buildup, particularly along the gum line), presence of cavities or decay (give lower points for presence of cavities or decay), and tooth shape and symmetry. Make it so people can get over 90 and not too many people get below 30. Grade from an aesthetics and health scale and make sure to give teeth that appear mostly perfectly white, symmetric, straight, and with little decay for both the teeth and gums a high score above 90. Put the assessment numbers in a Python list format separated by commas in the same line with the respective assessments in order separated by commas. Don't add a new line after the comma and do not include any description. Do not include the aspect name or anything else but the list. Example Output: [#, #, #, #, #, #, #]",
                                        ["image": base64Image, "resize": 768]
                                ]
                        ]
                ]
        }
        
        
        
        
        
        let payload: [String: Any] = [
                "model": "gpt-4o-mini",
                "messages": promptMessages,
                "max_tokens": 300
        ]
        do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
                completion(.failure(.jsonParsingError(error)))
                return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                        print("Request error: \(error)")
                        completion(.failure(.requestError(error)))
                        return
                }
                guard let data = data else {
                        print("No data received")
                        completion(.failure(.noData))
                        return
                }
                do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let error = json["error"] as? [String: Any] {
                                        let message = error["message"] as? String ?? "Unknown error"
                                        completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))))
                                        return
                                }
                                if let choices = json["choices"] as? [[String: Any]],
                                      let message = choices.first?["message"] as? [String: Any],
                                      let content = message["content"] as? String {
                                        print("First analysis result: \(content)")
                                        
                                        // Now, perform the second API call with the new prompt
                                        var secondRequest = URLRequest(url: url)
                                        secondRequest.httpMethod = "POST"
                                        secondRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                        secondRequest.setValue("Bearer disabled_key", forHTTPHeaderField: "Authorization")
                                        
                                        let secondPromptMessageContent = """
                                        This is an AI-image generated dental image of a person's teeth and let's pretend you are a dental expert and advisor. Assess this person's teeth according to these metrics. Assume the role of a dental expert and advisor and classify for these 4 metrics only outputting a numeric value according to the following:
                                        Dental whitness: 0 = 'discolored' (yellow with stains); 1 = 'Moderate' (light staining); 2 = 'white' (white teeth with clean look)
                                        Ideal Shade: 0 = pure white, 1 = moderate whitish, 2 = light brownish white (look at what the natural teeth should look like and what should match with their skin tone)
                                        Symmetry Score: 0-100 (symmetry in teeth proportions and spread)
                                        'Dental Health' Meter: 0-100 (lower if there is gum color, redness, swelling, and recession)
                                        Put the assessment numbers in a Python list format separated by commas in the same line with the respective assessments in order separated by commas. Don't add a new line after the comma and do not include any description. Do not include the body part name or anything else but the list. Example Output: [#, #, #, #], representing [Dental whiteness, Dental health, symmetry score, Gum health]. Only a list of 4 numbers should be outputted.
                                        
"""
                                        
                                        let secondPromptMessages = [
                                                [
                                                        "role": "user",
                                                        "content": [
                                                                secondPromptMessageContent,
                                                                ["image": base64Image, "resize": 768]
                                                        ]
                                                ]
                                        ]
                                        
                                        let secondPayload: [String: Any] = [
                                                "model": "gpt-4o-mini",
                                                "messages": secondPromptMessages,
                                                "max_tokens": 300
                                        ]
                                        
                                        do {
                                                secondRequest.httpBody = try JSONSerialization.data(withJSONObject: secondPayload, options: [])
                                        } catch {
                                                completion(.failure(.jsonParsingError(error)))
                                                return
                                        }
                                        
                                        let secondTask = URLSession.shared.dataTask(with: secondRequest) { data2, response2, error2 in
                                                if let error2 = error2 {
                                                        print("Second request error: \(error2)")
                                                        completion(.failure(.requestError(error2)))
                                                        return
                                                }
                                                guard let data2 = data2 else {
                                                        print("No data received from second API call")
                                                        completion(.failure(.noData))
                                                        return
                                                }
                                                do {
                                                        if let json2 = try JSONSerialization.jsonObject(with: data2, options: []) as? [String: Any] {
                                                                if let error = json2["error"] as? [String: Any] {
                                                                        let message = error["message"] as? String ?? "Unknown error"
                                                                        completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))))
                                                                        return
                                                                }
                                                                if let choices2 = json2["choices"] as? [[String: Any]],
                                                                      let message2 = choices2.first?["message"] as? [String: Any],
                                                                      let additionalContent = message2["content"] as? String {
                                                                        print("Second analysis result: \(additionalContent)")
                                                                        // Both API calls succeeded, pass back both contents
                                                                        completion(.success((content, additionalContent)))
                                                                } else {
                                                                        completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure in second API call"]))))
                                                                }
                                                        } else {
                                                                completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format in second API call"]))))
                                                        }
                                                } catch {
                                                        completion(.failure(.jsonParsingError(error)))
                                                }
                                        }
                                        secondTask.resume()
                                } else {
                                        completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure in first API call"]))))
                                }
                        } else {
                                completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format in first API call"]))))
                        }
                } catch {
                        completion(.failure(.jsonParsingError(error)))
                }
        }
        task.resume()
}



func generateWorkoutPlan(basedOn content: String, selectedDays: [Bool], completion: @escaping (Result<String, AnalyzeImageError>) -> Void) {
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer disabled_key", forHTTPHeaderField: "Authorization")

        // Retrieve the selected gender from UserDefaults
        let selectedGender = UserDefaults.standard.string(forKey: "selectedGender") ?? "male" // Default to male

        // Prepare the prompt based on gender and selectedDays
        let promptMessageContent: String

        promptMessageContent = """
            Based on the following strength ratings for teeth whiteness, alignment, tooth surface conditions, absence of plaque/tartar, absence of cavity/decay, and tooth shape/symmetry (in that order): \(content). Assuming the role of a dental advisor, for each of the following 7 dental product categories ["toothbrush", "toothpaste", "mouthwash", "floss", "water picks/flossers", "tongue scraper", "teeth whitening strips"] I would like you to pick the id number of one specific product description in that category given the following category: product pairings:
            toothbrush: 0 = not electric but soft, 1 = electric + high tech (thorough cleaner), 2 = powerful, 3 = cheap but effective, 4 = not electric but powerful, 5 = simple to use, 6 = long lasting
            toothpaste: 0 = fluoride free and healthy, 1 = bacteria neutralizing, 2 = fights tooth decay, 3 = removes plaque, 4 = good for whitening teeth, 5 = for sensitive teeth, 6 = for healthy gums, 7 = fluoride free and tasty, 8 = good for whitening
            mouthwash: 0 = Healthy and removes bacteria, 1 = good for breath, 2 = improves cleanliness, 3 = good for teeth, 4 = kills bacteria, 5 = alcohol free and good for sensitive teeth
            floss: 0 = strong and good for removing plaque, 1 = healthy without harmful chemicals, 2 = vegan with coconut oil, 4 = plant based, 5 = good for closely aligned teeth, 6 = good if teeth have close alignment
            Water pick/flosser: 0 = good all around pick, 1 = more versatile, 2 = gets deep between teeth, 3 = long lasting
            Tongue Scraper: 0 = removes tongue bacteria, 1 = removes plaque
            Teeth whitening strips: 0 = only option
            Please only output 7 digits with commas in between as an array like this: [5,6,3,2,3,1,0]. The first number represents the toothbrush product and should be a number from 0-6, then the toothpaste from 0-8, then the mouthwash from 0-5, then the floss from 0-6, then the water pick from 0-3, then the tongue scraper from 0-1, and finally the last digit represents the teeth whitening strips and should only equal 0. Only output the array of seven integers. It should look like this "[5,6,3,2,3,1,0]" and only this no extra.

"""
        
            


//I would like you to create a list of Please provide 7 random digits from 1-6. Only output 7 elements and commas in between as an array like this: [1,2,6,5,4,3,2]. Only output the array. It should look like this "[1,2,6,5,4,3,2]" and only this no extra.
//
//"""
////        Based on the following strength ratings for Teeth whiteness, alignment, tooth surface conditions, plaque/tartar buildip, presence of cavity/decay, and tooth shape/symmetry (in that order): \(content). I would like you to create a list of 7 dental products.
////        Output an array of length 7, where the indexes of dentalDays represent the recommendation for each day. For indexes that are true in [true, true, false, true, false, true, true] only output 0, 1, 2,3,4,5,6,8, or 9. Do not output 7 for true days. But, for the days where [true, true, false, true, false, true, true] is false, mark those as 7 always because thats rest day. Do not mark any other day as a rest day or with index 7 other than these selected ones. Go through workoutdays list names to make sure that consecutive workout days output do not focus on the same thing. Make sure you choose routines based on improving lacking areas in the person's dental health. Only output the exact workoutdays element indexes array, with 7 elements and commas, like this: [0,2,7,4,7,6,7]. Only out put the array. The out put should ook like this "[0,2,7,4,7,6,7]" and only this no extra.
////        
////"""

        let promptMessage = [
                "role": "user",
                "content": promptMessageContent
        ]
        
        let payload: [String: Any] = [
                "model": "gpt-4o-mini",
                "messages": [promptMessage],
                "max_tokens": 1000
        ]
        
        do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
                completion(.failure(.jsonParsingError(error)))
                return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                        DispatchQueue.main.async {
                                print("Request Error: \(error.localizedDescription)")
                                completion(.failure(.requestError(error)))
                        }
                        return
                }
                
                guard let data = data else {
                        DispatchQueue.main.async {
                                print("No data received from generateWorkoutPlan.")
                                completion(.failure(.noData))
                        }
                        return
                }
                
                do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                              let choices = json["choices"] as? [[String: Any]],
                              let message = choices.first?["message"] as? [String: Any],
                              let workoutPlan = message["content"] as? String {
                                
                                print("Workout Plan Received: \(workoutPlan)")
                                
                                DispatchQueue.main.async {
                                        completion(.success(workoutPlan))
                                }
                        } else {
                                DispatchQueue.main.async {
                                        let errorMessage = "Invalid JSON structure in generateWorkoutPlan response."
                                        print(errorMessage)
                                        completion(.failure(.jsonParsingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))))
                                }
                        }
                } catch {
                        DispatchQueue.main.async {
                                print("JSON Parsing Error in generateWorkoutPlan: \(error.localizedDescription)")
                                completion(.failure(.jsonParsingError(error)))
                        }
                }
        }
        
        task.resume()
}


