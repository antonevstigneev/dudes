//
//  UIImageExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 28.10.2020.
//

import Foundation
import UIKit


extension UIImage {
    func getPng() -> UIImage {
        let imageData = self.pngData()!
        let imagePng = UIImage(data: imageData)!
        return imagePng
    }
}

extension UIImage {
    func invertedImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CoreImage.CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputImageCopy, scale: self.scale, orientation: .up)
    }
}


extension UIImage {
    func convertToString(targetSize: CGSize = CGSize(width: 512, height: 512)) -> String {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!.pngData()?.base64EncodedString() ?? ""
    }
}



// MARK: - UIImage styles methods
extension UIImage {
    func applyFilter(_ style: Filter) -> UIImage {
        switch style {
        case .original:
            return self
        case .pixels:
            return self.pixelate()
        case .zoom:
            return self.zoom()
        case .metal:
            return self.shading("metal")
        case .gold:
            return self.shading("gold")
        case .neochrome:
            return self.shading("neochrome")
        case .outline:
            return self.outline()
        case .neon:
            return self.outline().glow().setRandomTint() // ⚠️ everytime applies new tint when filter applied
        case .neonpixels:
            return self.outline().glow().setRandomTint().pixelate()
        }
    }
    
    func pixelate(_ value: Int = Int.random(in: 10...12)) -> UIImage {
        var pixelatedImage: UIImage!
        let currentCGImage = self.cgImage
        let currentCIImage = CIImage(cgImage: currentCGImage!)
        
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(value, forKey: kCIInputScaleKey)
        var outputImage = filter?.outputImage
        
        let filter2 = CIFilter(name: "CIExposureAdjust")
        filter2?.setValue(outputImage, forKey: kCIInputImageKey)
        filter2?.setValue(3.0, forKey: "inputEV")
        
        outputImage = filter2?.outputImage
        
        let filter3 = CIFilter(name: "CIColorPosterize")
        filter3?.setValue(outputImage, forKey: kCIInputImageKey)
        filter3?.setValue(2, forKey: "inputLevels")
        
        outputImage = filter3?.outputImage
        
        let parameters = [
            "inputContrast": NSNumber(value: 10),
            "inputSaturation": NSNumber(value: 10)
        ]
        outputImage = outputImage!.applyingFilter("CIColorControls", parameters: parameters)
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent) {
            pixelatedImage = UIImage(cgImage: cgimg)
        }
        
        return pixelatedImage
    }
    
    func outline(glow: Bool = false) -> UIImage {
        var filteredImage: UIImage!
        let currentCGImage = self.cgImage
        let currentCIImage = CIImage(cgImage: currentCGImage!)
        
        let filter = CIFilter(name: "CIEdgeWork")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(2.0, forKey: "inputRadius")
        let outputImage = filter?.outputImage
    
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent) {
            filteredImage = UIImage(cgImage: cgimg)
        }
        
        return filteredImage
    }
    
    func shading(_ type: String) -> UIImage {
        var filteredImage: UIImage!
        var outputImage: CIImage!
        let currentCGImage = self.cgImage
        let currentCIImage = CIImage(cgImage: currentCGImage!)
        let inputShadingCGImage = UIImage(named: type)?.cgImage
        let inputShadingCIImage = CIImage(cgImage: inputShadingCGImage!)
        
        let filter = CIFilter(name: "CIHeightFieldFromMask")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        filter?.setValue(10.00, forKey: "inputRadius")
        outputImage = filter?.outputImage
        
        let filter2 = CIFilter(name: "CIShadedMaterial")
        filter2?.setValue(outputImage, forKey: kCIInputImageKey)
        filter2?.setValue(inputShadingCIImage, forKey: "inputShadingImage")
        filter2?.setValue(20.00, forKey: "inputScale")
        outputImage = filter2?.outputImage
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent) {
            filteredImage = UIImage(cgImage: cgimg)
        }
        
        return filteredImage
    }
    
    func glow() -> UIImage {
        let ciInputImage = CIImage(image: self)
        let ciOutputImage = ciInputImage?.applyingFilter("CIBloom",
                                                         parameters: [kCIInputRadiusKey: 6, kCIInputIntensityKey: 0.80 ])
        let context = CIContext()
        let cgOutputImage = context.createCGImage(ciOutputImage!, from: ciInputImage!.extent)
        return UIImage(cgImage: cgOutputImage!)
    }
    
    func zoom() -> UIImage {
        var filteredImage: UIImage!
        var outputImage: CIImage!
        let currentCGImage = self.cgImage
        let currentCIImage = CIImage(cgImage: currentCGImage!)
        
        let filter = CIFilter(name: "CIZoomBlur")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        filter?.setValue(CIVector(cgPoint: CGPoint(x: 64, y: 64)), forKey: "inputCenter")
        filter?.setValue(10.00, forKey: "inputAmount")
        outputImage = filter?.outputImage
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent) {
            filteredImage = UIImage(cgImage: cgimg)
        }
        
        return filteredImage
    }
}


extension UIImage {
    func setRandomTint(_ color: UIColor = .random) -> UIImage {
        
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create UIImage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        
        return newImage
    }
}

// save
extension UIImage {

    func save(at directory: URL,
              pathAndImageName: String,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
        
        return save(at: directory.appendingPathComponent(pathAndImageName),
                    createSubdirectoriesIfNeed: createSubdirectoriesIfNeed,
                    compressionQuality: compressionQuality)
        } 
    }

    func save(at url: URL,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
            if createSubdirectoriesIfNeed {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            guard let data = pngData() else { return nil }
            try data.write(to: url)
            return url
        } catch {
            print("-- Error: \(error)")
            return nil
        }
    }
}
