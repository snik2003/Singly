//
//  ImageProcessor.swift
//  Signly
//
//  Created by Сергей Никитин on 18.09.2022.
//

import UIKit
import Vision

struct ImageProcessor {
    static func pixelBuffer (forImage uiImage: UIImage?) -> CVPixelBuffer? {
        guard let uiImage = uiImage else { return nil }
        guard let image = uiImage.cgImage else { return nil}
        
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
            
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    static func detectRectangle(in image: CVPixelBuffer, forSize size: CGSize, shiftX: CGFloat, shiftY: CGFloat,
                                completion: @escaping ([CGPoint]?) -> Void) {
        
        DispatchQueue.global(qos: .utility).async {
            let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
                DispatchQueue.main.async {
                    guard let results = request.results as? [VNRectangleObservation] else {
                        completion(nil)
                        return
                    }
                    
                    guard results.count > 0 else {
                        completion(nil)
                        return
                    }
                    
                    guard var rect = results.first else {
                        completion(nil)
                        return
                    }
                    
                    for result in results {
                        print("\(result.boundingBox.width) - \(result.boundingBox.height)")
                        if result.boundingBox.width * result.boundingBox.height > rect.boundingBox.width * rect.boundingBox.height {
                            rect = result
                        }
                    }
                    
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -size.height)
                    let scale = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
                    let bounds = rect.boundingBox.applying(scale).applying(transform)
                    
                    /*guard bounds.width * bounds.height / (size.width * size.height) >= 0.5 else {
                        completion(nil)
                        return
                    }*/
                    
                    var points: [CGPoint] = []
                    points.append(CGPoint(x: bounds.minX + shiftX, y: bounds.minY + shiftY))
                    points.append(CGPoint(x: bounds.maxX + shiftX, y: bounds.minY + shiftY))
                    points.append(CGPoint(x: bounds.maxX + shiftX, y: bounds.maxY + shiftY))
                    points.append(CGPoint(x: bounds.minX + shiftX, y: bounds.maxY + shiftY))
                    
                    completion(points)
                }
            })
        
            request.minimumAspectRatio = VNAspectRatio(0.2)
            request.maximumAspectRatio = VNAspectRatio(1.0)
            request.minimumSize = Float(0.1)
            request.minimumConfidence = Float(0.6)
            request.maximumObservations = 1
        
            do {
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
                try imageRequestHandler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }
    
    static func detectRectangleIn(_ image: UIImage, forSize size: CGSize, shiftX: CGFloat, shiftY: CGFloat,
                                completion: @escaping ([CGPoint]?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let data = image.jpegData(compressionQuality: 1.0) else {
                completion(nil)
                return
            }
            
            let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
                DispatchQueue.main.async {
                    guard let results = request.results as? [VNRectangleObservation] else {
                        completion(nil)
                        return
                    }
                    
                    for result in results {
                        print("bounding box = \(result.boundingBox)")
                    }
                    
                    guard let rect = results.first else {
                        completion(nil)
                        return
                    }
                    
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -size.height)
                    let scale = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
                    let bounds = rect.boundingBox.applying(scale).applying(transform)
                    
                    var points: [CGPoint] = []
                    points.append(CGPoint(x: bounds.minX + shiftX, y: bounds.minY + shiftY))
                    points.append(CGPoint(x: bounds.maxX + shiftX, y: bounds.minY + shiftY))
                    points.append(CGPoint(x: bounds.maxX + shiftX, y: bounds.maxY + shiftY))
                    points.append(CGPoint(x: bounds.minX + shiftX, y: bounds.maxY + shiftY))
                    
                    completion(points)
                }
            })
        
            request.maximumAspectRatio = VNAspectRatio(1.0)
            request.minimumAspectRatio = VNAspectRatio(0.5)
            request.minimumConfidence = Float(0.2)
            request.maximumObservations = 10
            request.minimumSize = 0.6
            request.preferBackgroundProcessing = true
        
            do {
                let orientation = CGImagePropertyOrientation(image.imageOrientation)
                let imageRequestHandler = VNImageRequestHandler(data: data, orientation: orientation, options: [:])
                try imageRequestHandler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}

extension CGImagePropertyOrientation {
    
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left: self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
