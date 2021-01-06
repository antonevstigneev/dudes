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
            NSAttributedString.Key.foregroundColor : UIColor.black
        ])
        let alert = UIAlertController(title: "", message: message,  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        // alert styles
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "AccentColor")
        alert.view.tintColor = .black
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        
            self.showMainViewController()
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
                NSAttributedString.Key.foregroundColor : UIColor.black
            ])
            let alertController = UIAlertController(title: "", message: message,  preferredStyle: .alert)
            alertController.setValue(attributedString, forKey: "attributedTitle")
            
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


extension UIViewController {
    func showExplanataryAlert() {
        
        let attributedString = NSAttributedString(string: "SAVED!", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ])
        let showAlert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        showAlert.setValue(attributedString, forKey: "attributedTitle")
        showAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "AccentColor")
        showAlert.view.tintColor = .black
        let imageView = UIImageView(frame: CGRect(x: 10, y: 60, width: 250, height: 158))
        imageView.image = UIImage(named: "iMessageDudes")
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 285)
        let width = NSLayoutConstraint(item: showAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "Go to iMessage", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: "sms:")!, options: [:], completionHandler: nil)
            self.showMainViewController()
        }))
        self.present(showAlert, animated: true, completion: nil)
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
