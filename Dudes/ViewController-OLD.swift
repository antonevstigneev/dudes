//
//  ViewController.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 11.10.2020.
//

import UIKit
import CoreML
import CoreImage
import CoreImage.CIFilterBuiltins

class ViewController: UIViewController {
    
    let model = AbstractFaceModel()
    let emotionModel = EmotionModel()
    let faceCheckingModel = FaceCheckingModel()
    var potrace: Potrace!
    
    var width: Int!
    var height: Int!
    var imagePixels: [UInt8]!
    fileprivate var points: [CGPoint] = []
    
    @IBOutlet weak var toleranceSlider: UISlider!
    @IBOutlet weak var outputImage: UIImageView!
    @IBOutlet weak var outputVectorView: PolylineView!
    @IBOutlet weak var outputTracedView: UIImageView!
    
    @IBOutlet weak var emotionLabel: UILabel!
    
    // facechecking buttons
    @IBOutlet weak var faceCheckButton: UIButton!
    @IBOutlet weak var faceCrossButton: UIButton!
    
    // emotion buttons
    @IBOutlet weak var happyButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var amusedButton: UIButton!
    @IBOutlet weak var angryButton: UIButton!
    @IBOutlet weak var shockedButton: UIButton!
    @IBOutlet weak var skepticalButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    
    @IBAction func generateButtonTouchUpInside(_ sender: Any) {
        generateFace()
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: UIButton) {
        saveImage(outputTracedView.image!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        outputImage.isHidden = true
        toleranceSlider.isHidden = true
        
        faceCheckButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        faceCrossButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        
        happyButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        sadButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        amusedButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        angryButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        shockedButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        skepticalButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        neutralButton.addTarget(self, action: #selector(emotionTapped(_:)), for: .touchUpInside)
        
        generateFace()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
    
    func generateFace() {
        var generatedFace = model.genarate()
        
        if generatedFace[0] == Float.nan as NSObject || generatedFace[0] == Float.infinity as NSObject {
            generatedFace = model.genarate()
        }
        
        var m = MultiArray<Float>(generatedFace)
        m = m.reshaped([1, 128, 128])
        
        let image = m.image(channel: 0, offset: 0, scale: 256)

        outputImage.image = image
        guard let ciImage = CIImage(image: image!) else {
                        fatalError("Cannot convert to CIImage.")}
        
        if let originalImage = outputImage.image,
            let pixels = originalImage.pixelData() {

            self.width = Int(originalImage.size.width)
            self.height = Int(originalImage.size.height)
            self.imagePixels = pixels
            
            // add switch between modes:
            
//            drawPolylineFace(settings: Potrace.Settings())
            
            let faceChecking = self.faceCheckingModel.detect(image: ciImage)
            if faceChecking != "❎" {
                drawTracedFace(settings: Potrace.Settings())
            } else {
                generateFace()
            }
        }
        
        emotionLabel.text = self.emotionModel.detect(image: ciImage)
    }
    
    func collectSettings() -> Potrace.Settings {
        var settings = Potrace.Settings()
        settings.turdsize = 1
        settings.optcurve = true
        settings.opttolerance = 1
        
        return settings
    }
    
    func imageFromBezierPath(path: UIBezierPath, size: CGSize) -> UIImage {
        var image = UIImage()
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            path.fill()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            context.restoreGState()
            UIGraphicsEndImageContext()
        }
        
        return image
    }
    
    func drawPolylineFace(settings: Potrace.Settings) {
        self.potrace = Potrace(data: UnsafeMutableRawPointer(mutating: self.imagePixels),
                               width: self.width,
                               height: self.height)
        
        self.potrace.process(settings: settings)

        let tracedBezierPath = potrace.getBezierPath(scale: 3.5)
        let tracedCGPath = tracedBezierPath.cgPath
        
        // convert path to CGPoints array
        points = tracedCGPath.getPathElementsPoints()
    
        DispatchQueue.main.async {
            self.refreshPolylineView()
        }
    }
    
    
    func refreshPolylineView() {
        let tolerance = Float(toleranceSlider!.value)
        let highQuality = false

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let startTime = DispatchTime.now()
            let simplified = Simplify.simplify(self.points, tolerance: tolerance, highQuality: highQuality)
            let endTime = DispatchTime.now()
            
            let duration = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000.0
            
            DispatchQueue.main.async {
                self.outputVectorView.points = simplified
                self.outputVectorView.setNeedsDisplay()
                print("Simplified with duration \(duration)")
            }
        }
    }
    
    func drawTracedFace(settings: Potrace.Settings) {
        self.potrace = Potrace(data: UnsafeMutableRawPointer(mutating: self.imagePixels),
                               width: self.width,
                               height: self.height)
        
        self.potrace.process(settings: settings)
        let bezier = potrace.getBezierPath(scale: 2.5)
        
        DispatchQueue.main.async {
            let newImage = self.imageFromBezierPath(path: bezier, size: self.outputTracedView.frame.size)
            self.outputTracedView.image = newImage
        }
    }
    
    
    @objc func emotionTapped(_ sender: UIButton) {
        saveImageToDocumentDirectory(outputTracedView.image!, emotion: sender.currentTitle!)
        generateFace()
    }
    
    
    func saveImage(_ chosenImage: UIImage) {
        
        // Obtaining the Location of the Documents Directory
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Create URL
        let url = documents.appendingPathComponent(randomString(length: 6) + ".png")

        // Convert to Data
        if let data = chosenImage.pngData() {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Image Data to Disk")
            }
        }
    }
    
    
    
    func saveImageToDocumentDirectory(_ chosenImage: UIImage, emotion: String) {
        
        // Obtaining the Location of the Documents Directory
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Create URL
        let url = documents.appendingPathComponent(emotion + "/" + randomString(length: 6) + ".png")

        // Convert to Data
        if let data = chosenImage.pngData() {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Image Data to Disk")
            }
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

}


extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
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
