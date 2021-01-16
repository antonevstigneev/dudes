//
//  UIViewControllerExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 17.12.2020.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String, _ message: String = "") {

        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor : UIColor(named: "AccentColor")!
        ])
        let alert = UIAlertController(title: "", message: message,  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        // alert styles
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "ActionSheet")
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async() {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func showActionAlert(title: String!, message: String!, confirmation: String!, success: (() -> Void)? , cancel: (() -> Void)?) {
        DispatchQueue.main.async {
            let attributedString = NSAttributedString(string: title, attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor : UIColor.white
            ])
            let alertController = UIAlertController(title: "", message: message,  preferredStyle: .alert)
            alertController.setValue(attributedString, forKey: "attributedTitle")
            
            // alertController styles
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "ActionSheet")
            alertController.view.tintColor = UIColor(named: "AccentColor")
            
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


extension UIViewController {
    func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(identifier: "StickerpacksViewController")
        self.show(mainVC, sender: self)
    }
}
