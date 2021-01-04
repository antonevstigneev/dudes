//
//  SequenceExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 20.11.2020.
//

import Foundation
import UIKit

extension Sequence where Element: Hashable {
    var frequency: [Element: Int] { reduce(into: [:]) { $0[$1, default: 0] += 1 } }
}
