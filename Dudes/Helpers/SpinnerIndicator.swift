//
//  SpinnerIndicator.swift
//  Mind
//
//  Created by Anton Evstigneev on 26.06.2020.
//  Copyright © 2020 Anton Evstigneev. All rights reserved.
//

import Foundation
import UIKit

fileprivate var aView: UIView?

extension UIViewController {

    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        aView?.addSubview(activityIndicator)
        self.view.addSubview(aView!)
        self.view.bringSubviewToFront(aView!)
    }
    
    func removeSpinner() {
        DispatchQueue.main.async() {
            aView?.removeFromSuperview()
            aView = nil
        }
    }
}



