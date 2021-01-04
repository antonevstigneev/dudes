//
//  CVPixelBufferExtension.swift
//  AbstractFace
//
//  Created by Anton Evstigneev on 17.11.2020.
//

import Foundation
import UIKit

extension CVPixelBuffer {
    func bufferToArray() -> [UInt8] {

        var pixelBufferArray = [UInt8]()

        //Lock the base Address
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags.readOnly)

        //get pixel count
        let pixelCount = CVPixelBufferGetWidth(self) * CVPixelBufferGetHeight(self)

        //Get base address
        let baseAddress = CVPixelBufferGetBaseAddress(self)

        //Cast the base address to UInt8. This is like an array now
        let frameBuffer = baseAddress?.assumingMemoryBound(to: UInt8.self)

        pixelBufferArray = Array(UnsafeMutableBufferPointer(start: frameBuffer, count: pixelCount))
        
        //Unlock and release memory
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBufferArray
    }

}
