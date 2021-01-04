//
//  StringExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 08.12.2020.
//

import Foundation
import UIKit

extension String {
    static func random(length: Int = 9) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
