//
//  SmileCheckApp.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
//import Stripe
import SuperwallKit
import UserNotifications

@main
struct SmileCheckApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var globalContent = GlobalContent()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(globalContent)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    override init() {
        super.init()
        // Schedule daily reminders and discount notifications
        scheduleDailyNotification()
        // Perform the subscription check asynchronously to schedule discount notification if needed
        checkSubscriptionAndScheduleDiscount()
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Superwall with your API key
        Superwall.configure(apiKey: "pk_fe5d07ac24814c97591757559eb54e32acf3d521396808d7")
       
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//        
        FirebaseApp.configure()
        
        return true
    }
    
    // MARK: - Notification Scheduling

    // Schedule a daily notification at 6 PM
    private func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to scan your teeth today! Track progress daily."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18 // 6 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled successfully.")
            }
        }
    }
    
    // Schedule a discount notification 2 days after app installation and daily thereafter at 4 PM
    private func checkSubscriptionAndScheduleDiscount() {
        Task {
            do {
                let result = try await Superwall.shared.getPresentationResult(forEvent: "tab_trigger")
                switch result {
                case .userIsSubscribed, .holdout, .eventNotFound, .noRuleMatch, .paywallNotAvailable:
                    print("User is subscribed or no discount needed.")
                case .paywall:
                    //scheduleDiscountNotification()
                    print("could schedule Discount")
                }
            } catch {
                print("Error checking subscription status: \(error.localizedDescription)")
              //  scheduleDiscountNotification()
            }
        }
        print("checkSubscriptionAndSchedule")

    }
    
    private func scheduleDiscountNotification() {
        let center = UNUserNotificationCenter.current()
        
        let userDefaults = UserDefaults.standard
        let firstLaunchDateKey = "firstLaunchDate"
        
        var firstLaunchDate: Date
        if let savedDate = userDefaults.object(forKey: firstLaunchDateKey) as? Date {
            firstLaunchDate = savedDate
        } else {
            firstLaunchDate = Date()
            userDefaults.set(firstLaunchDate, forKey: firstLaunchDateKey)
        }
        
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: 2, to: firstLaunchDate) else {
            print("Error calculating trigger date for discount notification.")
            return
        }
        
        var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        triggerComponents.hour = 16 // 4 PM
        triggerComponents.minute = 0 // 00 minutes
        
        let content = UNMutableNotificationContent()
        content.title = "Too expensive?"
        content.body = "Here's a 40% off."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "discountReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling discount notification: \(error.localizedDescription)")
            } else {
                print("Discount reminder scheduled successfully.")
            }
        }
    }
}

