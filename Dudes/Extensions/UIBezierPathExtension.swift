//
//  UIBezierPathExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 07.11.2020.
//

import UIKit

extension UIBezierPath {
    convenience init(points: [CGPoint]) {
        self.init()

        for (index,aPoint) in points.enumerated() {
            if index == 0 {
                self.move(to: aPoint)
            }
            else {
                
                self.addLine(to: aPoint)
            }
        }
    }
    convenience init(points: [[[Int]]]) {
        self.init()
        
        if points.count > 1 {
            for i in 0..<points.count {
                for j in 0..<points[i].count{
                    if j == 0 {
                        self.move(to: CGPoint(x: points[i][j][0], y: points[i][j][1]))
                    } else {
                        self.addLine(to: CGPoint(x: points[i][j][0], y: points[i][j][1]))
                    }
                }
            }
        }

        
    }
}
