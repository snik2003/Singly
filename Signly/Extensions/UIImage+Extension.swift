//
//  UIImage+Extension.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func convertToBlackAndWhite() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
            
        guard let filter1 = CIFilter(name: "CIPhotoEffectNoir", parameters: [kCIInputImageKey: ciImage]) else { return nil }
        guard let grayImage = filter1.outputImage else { return nil }
            
        let bAndWParams: [String: Any] = [
            kCIInputImageKey: grayImage,
            kCIInputContrastKey: 50.0,
            kCIInputBrightnessKey: 10.0
        ]
            
        guard let filter2 = CIFilter(name: "CIColorControls", parameters: bAndWParams) else { return nil }
        guard let bAndWImage = filter2.outputImage else { return nil }
            
        guard let cgImage = CIContext(options: nil).createCGImage(bAndWImage, from: bAndWImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func convertToGrayScale() -> UIImage? {
        let imageRect = CGRect(x:0, y:0, width: size.width, height: size.height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = size.width
        let height = size.height

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8,
                                bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: imageRect)
        
        guard let imageRef = context?.makeImage() else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    func contrastImage(value: Float? = 25.0) -> UIImage? {
        guard let value = value else { return contrastImage(value: 25) }
        guard let cgImage = cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: nil)
        
        guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
        contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(value, forKey: kCIInputContrastKey)
        
        guard let outputImage = contrastFilter.outputImage else { return nil }
        guard let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImg)
    }
    
    func brightnessImage(value: Float? = 25.0) -> UIImage? {
        guard let value = value else { return brightnessImage(value: 25) }
        guard let cgImage = cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: nil)
        
        guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
        contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(value, forKey: kCIInputBrightnessKey)
        
        guard let outputImage = contrastFilter.outputImage else { return nil }
        guard let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImg)
    }
    
    func normalizedImage() -> UIImage? {
        guard self.imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalImage
    }
}
