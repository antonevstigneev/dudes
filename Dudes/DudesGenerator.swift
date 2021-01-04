//
//  DudesGenerator.swift
//  Dudes
//
//  Created by Anton Evstigneev on 03.12.2020.
//

import UIKit

class DudesGenerator {

    let dudesModel = DudesModel()
    let emotionModel = EmotionModel()
}

extension DudesGenerator {
    func generate() -> Dude {
        let dude = dudesModel.genarate()
        let dudeImage = dude.image
        guard let ciImage = CIImage(image: dudeImage) else {
                                fatalError("Cannot convert to CIImage.")}
        let detectedEmotion = emotionModel.detect(image: ciImage)

        let width = Int(dudeImage.size.width)
        let height = Int(dudeImage.size.height)
        var pixels = dude.pixelArray
        
        // check if generated face is broken
        let frequency = pixels.frequency
        for (_, value) in frequency {
            if value < 100 {
                return self.generate()
            }
        }
        
        // extract face skeleton path
        thinningZS(im: &pixels, W: width, H: height)
        let shapeSkeleton = traceSkeleton(im: &pixels, W: width, H: height, x: 0, y: 0, w: width, h: height, csize: 9, maxIter: 999)
        let outlinedImage = getOutlinedImage(from: shapeSkeleton)
        
        return Dude(emotion: detectedEmotion, image: outlinedImage, id: String.random(), timestamp: Date())
    }
}


extension DudesGenerator {
    func getOutlinedImage(from skeleton: [[[Int]]]) -> Data {
        let size: CGFloat = 128
        let rect = CGRect(origin: CGPoint.zero,
                          size: CGSize(width: size, height: size))
        
        let shapeLayer = CAShapeLayer()
        let dude = UIBezierPath(points: skeleton)
        
        let headSubLayer = CAShapeLayer()
        headSubLayer.path = dude.cgPath
        headSubLayer.fillColor = nil
        headSubLayer.strokeColor = UIColor.white.cgColor
        headSubLayer.lineCap = .round
        headSubLayer.lineJoin = .round
        headSubLayer.lineWidth = 30
        headSubLayer.shadowOpacity = 0.45
        headSubLayer.shadowOffset = CGSize(width: -0.1, height: 0.1)
        headSubLayer.shadowRadius = 4.5
        shapeLayer.addSublayer(headSubLayer)
            
        let faceSubLayer = CAShapeLayer()
        faceSubLayer.path = dude.cgPath
        faceSubLayer.fillColor = nil
        faceSubLayer.strokeColor = UIColor.black.cgColor
        faceSubLayer.lineWidth = 5
        faceSubLayer.lineCap = .round
        faceSubLayer.lineJoin = .round
        shapeLayer.addSublayer(faceSubLayer)

        let renderer = UIGraphicsImageRenderer(size: rect.size)
             
        let image = renderer.image { context in
            return shapeLayer.render(in: context.cgContext)
        }
        
        return image.pngData()!
    }
}

