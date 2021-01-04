//
//  SubscriptionViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 03.01.2021.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var subscriptionStackView: UIStackView!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var subscriptionButton: UIButton!
    
    @IBAction func manageSubscription(_ sender: UIButton) {
        if sender.titleLabel?.text == "SUBSCRIBE OR RESTORE" {
            showDudesUnlimViewController()
        } else {
            if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    override func viewDidLoad() {
        showSpinner()
        setupNotifications()
        IAPManager.shared.fetchProducts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IAPManager.shared.isSubscriptionActive { _ in }
    }

    @objc func subscriptionStatusChanged(_ notification: NSNotification) {
        guard let status = notification.object as? Bool else { return }
        
        DispatchQueue.main.async() { [self] in
            removeSpinner()
            subscriptionStackView.isHidden = false
            if status == true {
                subscriptionStatusLabel.text = "SUBSCRIPTION: ACTIVE"
                subscriptionButton.setTitle("MANAGE SUBSCRIPTIONS", for: .normal)
            } else {
                subscriptionStatusLabel.text = "SUBSCRIPTION: INACTIVE"
                subscriptionButton.setTitle("SUBSCRIBE OR RESTORE", for: .normal)
            }
        }
    }
}

extension SubscriptionViewController {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged(_:)), name: NSNotification.Name(IAPSubscriptionChangedNotification), object: nil)
    }
}
