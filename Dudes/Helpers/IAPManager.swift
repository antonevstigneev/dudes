//
//  IAPManager.swift
//  Dudes
//
//  Created by Anton Evstigneev on 26.12.2020.
//

import Foundation
import StoreKit

let IAPSubscriptionFailureNotification = "IAPSubscriptionFailureNotification"
let IAPSubscriptionRestoreNotification = "IAPSubscriptionRestoreNotification"
let IAPSubscriptionChangedNotification = "IAPSubscriptionChangedNotification"

protocol IAPServiceDelegate {
    func iapProductsLoaded()
}

class IAPManager: SKReceiptRefreshRequest, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    var iapDelegate: IAPServiceDelegate?
    
    var products: [SKProduct] = []
    var prices: [String] = []

    private var completion: ((Bool) -> ())?
    
    enum Product: String, CaseIterable {
        case unlimMonthly = "com.getdudesapp.Dudes.Unlim.Monthly"
        case unlimYearly = "com.getdudesapp.Dudes.Unlim.Yearly"
    }
    
    enum PurchaseStatus {
        case failed
        case restored
        case subscribed
    }
    
    public func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        if products.count == 0 {
            fetchProducts()
        } else {
            for product in products {
                prices.append(product.localizedPrice!)
            }
            iapDelegate?.iapProductsLoaded()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKProductsRequest else {
            return
        }
        print("Product fetch request failed")
    }
    
    // prompt payment transaction
    public func purchase(product: SKProduct, completion: @escaping ((Bool) -> ())) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        self.completion = completion
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(self)
    }
    
    // observe transaction
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({ transaction in
            switch transaction.transactionState {
            case .purchased:
                completion?(true)
                sendNotification(for: .subscribed, bool: true)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                completion?(true)
                sendNotification(for: .restored, bool: nil)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                completion?(false)
                sendNotification(for: .failed, bool: nil)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                print("Purchasing...")
                break
            @unknown default:
                break
            }
        })
    }
    
    func requestDidFinish(_ request: SKRequest) {
        isSubscriptionActive { [self] active in
            if active {
                sendNotification(for: .subscribed, bool: true)
            } else {
                sendNotification(for: .subscribed, bool: false)
            }
        }
    }
    
    func isSubscriptionActive(completionHandler: @escaping (Bool) -> ()) {
        // Get the receipt if it's available
        var receiptString: String!
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                receiptString = receiptData.base64EncodedString(options: [])
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                completionHandler(false)
            }
        }
        
        if receiptString == nil {
            completionHandler(false)
            return
        }
    
        verifyReceipt(receipt: receiptString) { (responseData, error)  in
            if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject (with: responseData, options: []) as! Dictionary<String, Any>
                let isSubscriptionActive = json["isSubscriptionActive"] as! Bool
    
                if isSubscriptionActive == true {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
        }
    }
}


// notification
extension IAPManager {
    func sendNotification(for state: PurchaseStatus, bool: Bool?) {
        switch state {
        case .failed:
            NotificationCenter.default.post(name: NSNotification.Name(IAPSubscriptionFailureNotification), object: nil)
        case .restored:
            NotificationCenter.default.post(name: NSNotification.Name(IAPSubscriptionRestoreNotification), object: nil)
        case .subscribed:
            NotificationCenter.default.post(name: NSNotification.Name(IAPSubscriptionChangedNotification), object: bool)
        }
    }
}


// price localization
extension SKProduct {
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}
