//
//  UIImageView+Extension.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit
import AVFoundation
import Photos

extension UIImageView {
    func fetchImageAsset(_ asset: PHAsset?, targetSize size: CGSize, contentMode: PHImageContentMode = .aspectFill, options: PHImageRequestOptions? = nil, completionHandler: ((Bool) -> Void)?) {

        guard let asset = asset else {
            completionHandler?(false)
            return
        }
      
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            self.image = image
            completionHandler?(true)
        }
      
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode,
                                              options: options, resultHandler: resultHandler)
    }
    
    func getEditedImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func editedImage() -> UIImage? {
        guard let image = self.image else { return nil }
        
        let imsize = image.size
        let ivsize = bounds.size

        let scale1: CGFloat = ivsize.width / imsize.width
        let scale2: CGFloat = ivsize.height / imsize.height
        
        let croppedImageSize = CGSize(width: ivsize.width / scale1, height: ivsize.height / scale2)
        let croppedImage = UIGraphicsImageRenderer(size: croppedImageSize).image { _ in }
        
        return croppedImage
    }
    
    func drawByPoints(_ pointsArray: [[CGPoint]], cgColor: CGColor, width: CGFloat, scale: CGFloat = 1.0) {
        guard pointsArray.count > 0 else { return }
        self.image = nil
        
        for index2 in 0 ..< pointsArray.count {
            let points = pointsArray[index2]
            guard points.count > 0 else { continue }
            
            if points.count == 1 {
                let point = CGPoint(x: points[0].x * scale, y: points[0].y * scale)
                
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
                self.image?.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
                
                let context = UIGraphicsGetCurrentContext()
                context?.setLineCap(.round)
                context?.setLineWidth(width)
                context?.setStrokeColor(cgColor)
                context?.setBlendMode(.normal)
                context?.move(to: point)
                context?.addLine(to: point)
                context?.strokePath()
                context?.flush()
                
                self.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
            } else {
                for index in 1 ..< points.count {
                    let lastPoint = CGPoint(x: points[index - 1].x * scale, y: points[index - 1].y * scale)
                    let currentPoint = CGPoint(x: points[index].x * scale, y: points[index].y * scale)
                    
                    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
                    image?.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
                
                    let context = UIGraphicsGetCurrentContext()
                    context?.move(to: lastPoint)
                    context?.addLine(to: currentPoint)
                    context?.setLineCap(.round)
                    context?.setLineWidth(width)
                    context?.setStrokeColor(cgColor)
                    context?.setBlendMode(.normal)
                    context?.strokePath()
                    
                    image = UIGraphicsGetImageFromCurrentImageContext()
                    alpha = 1.0
                    UIGraphicsEndImageContext()
                }
            }
        }
    }
    
    func drawCropperByPoints(_ points: [CGPoint], middlePoints: [CGPoint], cgColor: CGColor, radius: CGFloat = 0.0, width: CGFloat = 6.0) {
        
        image = nil
        guard points.count > 0 else { return }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
    
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setStrokeColor(cgColor)
        context.setBlendMode(.normal)
        
        context.beginPath()
        context.move(to: CGPoint(x: points[0].x + radius, y: points[0].y))
        context.addLine(to: CGPoint(x: points[1].x + radius, y: points[1].y))
        context.move(to: CGPoint(x: points[1].x, y: points[1].y + radius))
        context.addLine(to: CGPoint(x: points[2].x, y: points[2].y - radius))
        context.move(to: CGPoint(x: points[2].x - radius, y: points[2].y))
        context.addLine(to: CGPoint(x: points[3].x + radius, y: points[3].y))
        context.move(to: CGPoint(x: points[3].x, y: points[3].y - radius))
        context.addLine(to: CGPoint(x: points[0].x, y: points[0].y + radius))
        context.strokePath()
        
        if middlePoints.count > 0 {
            context.setLineWidth(width / 2)
            context.beginPath()
            
            if abs(middlePoints[0].x - middlePoints[2].x) < 10 {
                context.move(to: CGPoint(x: middlePoints[0].x, y: middlePoints[0].y + radius))
                context.addLine(to: CGPoint(x: middlePoints[2].x, y: middlePoints[2].y - radius))
            }
            
            if abs(middlePoints[1].y - middlePoints[3].y) < 10 {
                context.move(to: CGPoint(x: middlePoints[1].x + radius, y: middlePoints[1].y))
                context.addLine(to: CGPoint(x: middlePoints[3].x - radius, y: middlePoints[3].y))
            }
            
            context.strokePath()
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
