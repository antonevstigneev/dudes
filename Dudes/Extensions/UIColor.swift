//
//  UIColor.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 07.11.2020.
//

import UIKit

// TODO: Add color corresponding for detected emotion
enum Emotion: String, CaseIterable {
    case 😮, 😠, 😐, 🙁, 🙂
}

extension UIColor {
    static var random: UIColor {
        return .init(hue: .random(in: 0...1),
                     saturation: .random(in: 0.5...1),
                     brightness: 1,
                     alpha: 1)
    }
}

extension UIColor {
    func getComplementary() -> UIColor {
        let ciColor = CIColor(color: self)
        
        let compRed: CGFloat = 1.0 - ciColor.red
        let compGreen: CGFloat = 1.0 - ciColor.green
        let compBlue: CGFloat = 1.0 - ciColor.blue
        
        return UIColor(red: compRed, green: compGreen, blue: compBlue, alpha: 1.0)
    }
}

