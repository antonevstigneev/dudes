//
//  AboutViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 30.12.2020.
//

import UIKit
import MessageUI

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
    
    @IBAction func sendFeedback(_ sender: Any) {
        sendFeedback()
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


extension AboutViewController: MFMailComposeViewControllerDelegate {
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.view.tintColor = .systemBlue
            mail.overrideUserInterfaceStyle = .dark
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hi@getdudesapp.com"])
            mail.setSubject("Feedback")
            mail.setMessageBody("<br><br><br><p style='color:gray;'>\(UIDevice().type), iOS: \(getOSInfo())",
                                isHTML: true)

            present(mail, animated: true)
        } else {
            print("Error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
