//
//  DudesUnlimViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 26.12.2020.
//

import UIKit
import StoreKit

class DudesUnlimViewController: UIViewController {

    @IBOutlet weak var subscriptionFeatures: UIStackView!
    @IBOutlet weak var subscriptionProducts: UIStackView!
    @IBOutlet weak var monthlySubscriptionButton: UIButton!
    @IBOutlet weak var yearlySubscriptionButton: UIButton!

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func getSubscription(_ sender: UIButton) {
        if !NetworkState.isConnectedToNetwork() {
            self.showAlert("No internet connection")
        } else {
            self.showSpinner()
            let product = Int(sender.accessibilityIdentifier!)

            if IAPManager.shared.products.count != 0 {
                IAPManager.shared.purchase(product: IAPManager.shared.products[product!]) { completion in
                    self.removeSpinner()
                    if completion {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.removeSpinner()
                showAlert("Error", "Please try again later.")
            }
        }
    }

    @IBAction func restorePurchases(_ sender: Any) {
        if !NetworkState.isConnectedToNetwork() {
            self.showAlert("No internet connection")
        } else {
            showSpinner()
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }

    @IBAction func privacyPolicy(_ sender: Any) {
        if let url = URL(string: Legal.privacy.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func termsOfUse(_ sender: Any) {
        if let url = URL(string: Legal.terms.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    override func viewDidLoad() {
        setupNotifications()
        showSpinner()
        IAPManager.shared.iapDelegate = self
        IAPManager.shared.fetchProducts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func subscriptionRestoration() {
        removeSpinner()
        IAPManager.shared.isSubscriptionActive { active in
            DispatchQueue.main.async {
                if active {
                    self.showAlert("Subscription restored",
                              "Your purchased subscription was successfully restored.")
                } else {
                    self.showAlert("No active subscriptions",
                              "You don't have any active subscriptions to restore.")
                }
            }
        }
    }

    @objc func purchaseFailed() {
        self.showAlert("Purchase failed.")
    }

    func hideSubscriptionProducts(_ bool: Bool) {
        subscriptionFeatures.isHidden = bool
        subscriptionProducts.isHidden = bool
    }
}


extension DudesUnlimViewController: IAPServiceDelegate {
    func iapProductsLoaded() {
        let monthlyPrice = IAPManager.shared.prices[0]
        let yearlyPrice = IAPManager.shared.prices[1]
        DispatchQueue.main.async() { [self] in
            removeSpinner()
            hideSubscriptionProducts(false)
            monthlySubscriptionButton.setTitle("1 MONTH: " + monthlyPrice, for: .normal)
            yearlySubscriptionButton.setTitle("1 YEAR: " + yearlyPrice, for: .normal)
        }
    }
}


extension DudesUnlimViewController {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoration), name: NSNotification.Name(IAPSubscriptionRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: NSNotification.Name(IAPSubscriptionFailureNotification), object: nil)
    }
}



