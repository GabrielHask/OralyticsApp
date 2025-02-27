//
//  GlobalContent.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

class GlobalContent: ObservableObject {
    
    @Published var selectedDays: [Bool] = Array(repeating: false, count: 7)
{
        didSet {
            saveSelectedDaysToUserDefaults()
        }
    }
    
    @Published var content: [Int] = []
    @Published var overallRating: Int = 0 // Added
    @Published var ratings2: [Int] = []
    @Published var potentialRating: Int = 0 // Added
    @Published var workoutPlan: String = ""
    @Published var globalImage: Data? // Store the image as Data
    @Published var email: String? // Store the email
    @Published var customerId: String?
    @Published var username: String? // Store the Stripe customer ID
    @Published var savedContent: [Int] = []
    @Published var physiqueMetrics: [Int] = []
    @Published var analysisCompleted: Bool = false
    @Published var navigateToTabBar: Bool = false
    @Published var morningProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @Published var middayProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    @Published var eveningProducts: [Int] = [-1,-1,-1,-1,-1,-1,-1]
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        loadSelectedDaysFromUserDefaults()
        loadEmailFromUserDefaults() // Load email when the class is initialized
    }
    
    // MARK: - Selected Days Persistence
    
    /// Loads the selected workout days from UserDefaults.
    func loadSelectedDaysFromUserDefaults() {
        if let savedDays = UserDefaults.standard.array(forKey: "selectedWorkoutDays") as? [Bool], savedDays.count == 7 {
            self.selectedDays = savedDays
            print("Selected Days loaded from UserDefaults: \(savedDays)")
        } else {
            print("No selected days found in UserDefaults or invalid data. Using default values.")
            print("No selected days found in UserDefaults or invalid data. Using default values.")
        }
    }

    
    /// Saves the selected workout days to UserDefaults.
    func saveSelectedDaysToUserDefaults() {
        UserDefaults.standard.set(selectedDays, forKey: "selectedWorkoutDays")
        print("Selected Days Saved to UserDefaults: \(selectedDays)")
    }

    
    // MARK: - Email Persistence
    
    /// Loads the email from UserDefaults.
    private func loadEmailFromUserDefaults() {
        if let savedEmail = UserDefaults.standard.string(forKey: "email") {
            self.email = savedEmail
            print("Email loaded from UserDefaults: \(savedEmail)")
        } else {
            print("No email found in UserDefaults.")
        }
    }
    
    // MARK: - Firestore Operations
    
    func addToLeaderboard() {
        // Check if email is available in UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("Email is not set in UserDefaults.")
            return
        }

        // Check if username is set, break if it is nil
        guard let username = username else {
            print("Username is not set.")
            return
        }

        // Calculate the average of the content array
        let average: Double
        if content.isEmpty {
            average = 0
        } else {
            let sum = content.reduce(0, +)
            average = Double(sum) / Double(content.count)
        }

        // Create the data to be added to Firestore
        let data: [String: Any] = [
            "username": username,
            "overall": Int(average)
        ]
        
        // Add the data to Firestore
        db.collection("leaderboard").document(email).setData(data) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    func compressImage(data: Data, maxSizeBytes: Int = 400000) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        var compressionQuality: CGFloat = 1.0
        var compressedData = image.jpegData(compressionQuality: compressionQuality)
        
        // Debugging the original size
        print("Original image size: \(CGFloat(data.count) / (1024 * 1024)) MB")
        
        // Loop to compress the image until it fits within the size limit
        while let data = compressedData, data.count > maxSizeBytes {
            compressionQuality -= 0.1
            compressedData = image.jpegData(compressionQuality: compressionQuality)
            
            // Debugging the current compression quality and size
            print("Compression Quality: \(compressionQuality), Size: \(CGFloat(data.count) / (1024 * 1024)) MB")
            
            // If the compression quality drops below 0.1, stop compressing to avoid poor quality
            if compressionQuality <= 0.1 {
                print("Image could not be compressed below the Firestore limit without significant quality loss.")
                break
            }
        }
        
        // Debugging the final size after compression
        if let compressedData = compressedData {
            print("Final compressed image size: \(CGFloat(compressedData.count) / (1024 * 1024)) MB")
        }
        
        return compressedData
    }

    func saveRatings() {
        guard let email = email, !content.isEmpty else {
            print("Email is nil or content is empty")
            return
        }
        
        // Ensure the content array has exactly 7 numbers
        guard content.count == 7 else {
            print("Content array does not have 7 numbers: \(content)")
            return
        }
        
        let ratings = content
        let ratings2 = self.ratings2
        let timestamp = Timestamp(date: Date())
        let userDoc = db.collection("userRatings").document(email)
        let timestampDoc = userDoc.collection("timestamps").document("\(timestamp.seconds)")
        
        // Compress and convert globalImage to Base64-encoded string if available
        let globalImageBase64: String?
        if let imageData = globalImage {
            if let compressedData = compressImage(data: imageData) {
                globalImageBase64 = compressedData.base64EncodedString()
            } else {
                globalImageBase64 = nil
            }
        } else {
            globalImageBase64 = nil
        }
        
        // Debugging prints
        print("Saving ratings for email: \(email)")
        print("Ratings to be saved: \(ratings)")
        print("Ratings2 to be saved: \(ratings2)")
        print("Timestamp to be saved: \(timestamp)")
        
        timestampDoc.setData([
            "rating": ratings,
            "ratings2": ratings2, // Save the new ratings2 array
            "timestamp": timestamp,
            "globalImage": globalImageBase64 ?? ""
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully written!")
                DispatchQueue.main.async {
                    self.analysisCompleted = true // Set analysisCompleted to true
                }
            }
        }
    }
    
    func saveProductList() {
        guard let email = email, !morningProducts.isEmpty, !middayProducts.isEmpty, !eveningProducts.isEmpty else {
            print("Email is nil or products lists are empty")
            return
        }
        
        // Ensure the content array has exactly 7 numbers
        guard morningProducts.count == 7, middayProducts.count == 7, eveningProducts.count == 7 else {
            print("Product arrays do not have 7 numbers: \(content)")
            return
        }
        
        let morningProducts = self.morningProducts
        let middayProducts = self.middayProducts
        let eveningProducts = self.eveningProducts
        let timestamp = Timestamp(date: Date())
        let userDoc = db.collection("productList").document(email)
        let timestampDoc = userDoc.collection("timestamps").document("\(timestamp.seconds)")
        
        // Compress and convert globalImage to Base64-encoded string if available
        
        // Debugging prints
        print("Saving ratings for email: \(email)")
        print("Morning products to be saved: \(morningProducts)")
        print("Midday products to be saved: \(middayProducts)")
        print("Evening products to be saved: \(eveningProducts)")
        print("Timestamp to be saved: \(timestamp)")
        
        timestampDoc.setData([
            "morningProducts": morningProducts,
            "middayProducts": middayProducts,
            "eveningProducts": eveningProducts,
            "timestamp": timestamp,
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully written!")
                DispatchQueue.main.async {
                    self.analysisCompleted = true // Set analysisCompleted to true
                }
            }
        }
    }

}
