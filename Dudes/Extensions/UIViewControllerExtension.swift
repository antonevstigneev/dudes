//
//  UIViewControllerExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 17.12.2020.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String, _ message: String = "", installTelegram: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // alert styles
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "AccentColor")
        alert.view.tintColor = .black
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        let installAction = UIAlertAction(title: "App Store", style: UIAlertAction.Style.default) {
            UIAlertAction in
            if let url = URL(string: "itms-apps://apple.com/app/id686449807") {
                UIApplication.shared.open(url)
            }
        }
        
        if installTelegram {
            alert.addAction(cancelAction)
            alert.addAction(installAction)
        } else {
            alert.addAction(okAction)
        }
        
        DispatchQueue.main.async() {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func showActionAlert(title: String!, message: String!, confirmation: String!, success: (() -> Void)? , cancel: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            // alertController styles
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "AccentColor")
            alertController.view.tintColor = .black
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel",
                                                            style: .default) {
                                                                action -> Void in cancel?()
            }
            let successAction: UIAlertAction = UIAlertAction(title: confirmation,
                                                             style: .default) {
                                                                action -> Void in success?()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(successAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}



// MARK: - Sharing method
extension UIViewController {

    func shareImages(_ images: [UIImage]) {
        let pngImages = images.map { $0.getPng() }
        let activityViewController = UIActivityViewController(activityItems: pngImages, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}


