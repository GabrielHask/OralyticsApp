import Foundation
import StoreKit

@available(iOS 15.0, *)
class PurchaseManager: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var isSubscribed: Bool = false
    
    private let subscriptionProductID = "123abcWeeklyProd"
    private let hasSubscriptionKey = "hasSubscription"
    private let subscriptionExpirationDateKey = "subscriptionExpirationDate"
    
    override init() {
        super.init()
        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
        }
    }

    // Fetch available products from the App Store
    func fetchProducts() async {
        do {
            let productIDs = Set([subscriptionProductID])
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts
            print("Available products: \(products)")
        } catch {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }

    // Purchase a product
    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await handleTransaction(transaction)
                case .unverified:
                    print("Purchase verification failed.")
                }
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase is pending.")
            default:
                print("Unknown purchase result.")
            }
        } catch {
            print("Purchase failed with error: \(error.localizedDescription)")
        }
    }

    // Handle a verified transaction
    private func handleTransaction(_ transaction: Transaction) async {
        if transaction.productID == subscriptionProductID {
            if let expirationDate = transaction.expirationDate {
                // Calculate new expiration date
                let newExpirationDate = Date().addingTimeInterval(expirationDate.timeIntervalSinceNow)
                storeExpirationDate(newExpirationDate)
                isSubscribed = true
                print("Transaction verified. New expiration date: \(newExpirationDate)")
            } else {
                // Handle case where expirationDate is nil
                print("Transaction has no expiration date.")
                isSubscribed = false
            }
            await transaction.finish()
        }
    }

    // Restore previously purchased products
    func restorePurchases() async {
        await fetchProducts() // Refresh product list
        await checkSubscriptionStatus() // Recheck subscription status
    }

    // Check the subscription status
    func checkSubscriptionStatus() async {
        if let expirationDate = getStoredExpirationDate() {
            // Check if the subscription has expired
            if Date() < expirationDate {
                isSubscribed = true
                print("Subscription is active. Expiration date: \(expirationDate)")
            } else {
                // Subscription has expired
                isSubscribed = false
                clearSubscriptionData()
                print("Subscription has expired. Expiration date: \(expirationDate)")
            }
        } else {
            // No expiration date found, subscription is not active
            isSubscribed = false
            clearSubscriptionData()
            print("No expiration date found. Subscription is not active.")
        }
    }

    // Store the subscription expiration date
    private func storeExpirationDate(_ expirationDate: Date) {
        UserDefaults.standard.set(expirationDate, forKey: subscriptionExpirationDateKey)
        UserDefaults.standard.set(true, forKey: hasSubscriptionKey) // Ensure hasSubscription is set
    }

    // Retrieve the stored subscription expiration date
    private func getStoredExpirationDate() -> Date? {
        return UserDefaults.standard.object(forKey: subscriptionExpirationDateKey) as? Date
    }

    // Clear subscription data
    private func clearSubscriptionData() {
        UserDefaults.standard.removeObject(forKey: subscriptionExpirationDateKey)
        UserDefaults.standard.set(false, forKey: hasSubscriptionKey)
    }
}
