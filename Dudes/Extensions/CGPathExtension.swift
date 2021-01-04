//
//  CGPathExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 07.11.2020.
//

import UIKit

extension CGPath {
    
    func resizepath(to frame: CGRect) -> CGPath {
        
        let boundingBox = self.boundingBox
        let boundingBoxAspectRatio = boundingBox.width / boundingBox.height
        let viewAspectRatio = frame.width / frame.height
        var scaleFactor: CGFloat = 1.0
        
        if (boundingBoxAspectRatio > viewAspectRatio) {
            scaleFactor = frame.width / boundingBox.width
        } else {
            scaleFactor = frame.height / boundingBox.height
        }
        
        var scaleTransform = CGAffineTransform.identity
        scaleTransform = scaleTransform.scaledBy(x: scaleFactor, y: scaleFactor)
        scaleTransform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY)
        
        let scaledSize = boundingBox.size.applying(CGAffineTransform (scaleX: scaleFactor, y: scaleFactor))
        let centerOffset = CGSize(width: (frame.width - scaledSize.width ) / scaleFactor * 2.0, height: (frame.height - scaledSize.height) /  scaleFactor * 2.0 )
        scaleTransform = scaleTransform.translatedBy(x: centerOffset.width, y: centerOffset.height)
        let scaledPath = self.copy(using: &scaleTransform)
        
        return scaledPath!
    }
}


extension CGPath {
    
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}
