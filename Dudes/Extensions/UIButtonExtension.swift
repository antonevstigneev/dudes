//
//  UIButtonExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 10.12.2020.
//

import UIKit

// MARK: - UIButton Show/Hide
public extension UIButton {

    func show() {
        self.isHidden = false
        self.isEnabled = true
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 2, options: [.allowUserInteraction, .curveEaseIn], animations: {
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 2, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    func hide() {
        self.isHidden = false
        self.isEnabled = false
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 2, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
}
