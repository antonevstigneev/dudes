//
//  EmotionModel.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 20.10.2020.
//

import UIKit
import CoreML
import Vision

class EmotionModel {
    
    // Declare a function for image classification
    func detect(image: CIImage) -> String {
        var detectedEmotion: String = ""
        guard let model = try? VNCoreMLModel(for: emotion_classifier().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
//            let confidence = results.first!.confidence
//            print(confidence)
            detectedEmotion = results.first!.identifier.capitalized
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
        return detectedEmotion
    }
}
