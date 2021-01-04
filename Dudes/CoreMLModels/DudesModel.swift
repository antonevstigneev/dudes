//
//  DudesModel.swift
//  dude
//
//  Created by Anton Evstigneev on 11.10.2020.
//

import CoreML
import UIKit


class DudesModel {
    
    var imageOutputResult: UIImage!
    
    public func genarate() -> (image: UIImage, pixelArray: [UInt8]) {
        
        // generates latent_vector for input
        guard let randomInput = try? MLMultiArray(shape: [1, 100], dataType: .float32) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        let randomFloats = (1..<100).map { _ in Float.random(in: -2.5..<2.5) }
        
        for (index, element) in randomFloats.enumerated() {
            randomInput[index] = NSNumber(value: element)
        }

        let input = dudesInput(input_1: randomInput)
        
        let options = MLPredictionOptions()
        options.usesCPUOnly = true
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        
        guard let output = try? dudes(configuration: config).prediction(input: input, options: options) else {
                fatalError("Unexpected runtime error. model.prediction")
        }
        
        let pixelBuffer = output.image_output
        let pixelArray = pixelBuffer.bufferToArray()
        var pixels: [UInt8] = []
        for p in 0..<pixelArray.count {
            pixels.append(255 - pixelArray[p])
        }

        var bitmap: [UInt8] = []
        for p in 0..<pixelArray.count {
            let pixel = pixels[p]
            if (pixel > 127) {
                bitmap.append(1)
            }else{
                bitmap.append(0)
            }
        }

        if let image = UIImage(pixelBuffer: pixelBuffer, context: CIContext()) {
            self.imageOutputResult = image.invertedImage()
        }
     
        return (image: imageOutputResult, pixelArray: bitmap)
    }
}


