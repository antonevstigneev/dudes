//
//  AboutViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 30.12.2020.
//

import UIKit

class AboutViewController: UIViewController {
    
    // MARK: - Outlets
    @IBAction func termsOfUse(_ sender: Any) {
        if let url = URL(string: Legal.terms.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func privacyPolicy(_ sender: Any) {
        if let url = URL(string: Legal.privacy.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppVersion()
    }
}

extension AboutViewController {
    func getAppVersion() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        appVersionLabel.text = "DUDES V\(version)"
    }
}
