//
//  CGPointExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 01.11.2020.
//

import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}
