//
//  PhotoUtilities.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI
import Photos
import CoreML
import Vision
import UIKit
import VideoToolbox
    
class PhotoUtilities {
    static let model = try! VNCoreMLModel(for: Resnet50().model)
    
    static func category(for image: UIImage) -> String? {
        var category: String?
        
        guard let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) else { return nil }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            if let firstResult = results.first {
                category = firstResult.identifier
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
        return category
    }
}


extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                                           kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
}
