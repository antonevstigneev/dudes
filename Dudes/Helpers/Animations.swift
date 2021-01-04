//
//  Animations.swift
//  Dudes
//
//  Created by Anton Evstigneev on 07.12.2020.
//

import Foundation
import UIKit

// MARK: - Cell selection animation
public extension UICollectionViewCell {
    
    func animate() {
        UIView.animate(withDuration: 0.06, delay: 0.0, usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (_) in
            UIView.animate(withDuration: 0.08, delay: 0.0, usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.2, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
}

extension UILabel {

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }

}
