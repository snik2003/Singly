//
//  UIView+Extension.swift
//  CDL
//
//  Created by Сергей Никитин on 08.08.2022.
//

import UIKit

extension UIView {
    
    func gradientBackgroundColor(color1: UIColor, color2: UIColor) {
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        let layer = CAGradientLayer()
        layer.colors = [color1.cgColor, color2.cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        let transform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        layer.transform = CATransform3DMakeAffineTransform(transform)
        
        layer.frame = bounds.insetBy(dx: -0.5 * bounds.size.width, dy: -0.5 * bounds.size.height)
        layer.position = center
        self.layer.insertSublayer(layer, at: 0)
    }
    
    func gradientBackgroundColor2(color1: UIColor, color2: UIColor) {
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        let layer = CAGradientLayer()
        layer.colors = [color1.cgColor, color2.cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        let transform = CGAffineTransform(a: 0.29, b: 2.48, c: -2.48, d: 7.02, tx: 1.24, ty: -3.56)
        layer.transform = CATransform3DMakeAffineTransform(transform)
        
        layer.frame = bounds.insetBy(dx: -0.5 * bounds.size.width, dy: -0.5 * bounds.size.height)
        layer.position = center
        self.layer.insertSublayer(layer, at: 0)
    }
    
    func border(width: CGFloat = 0, color: UIColor? = nil, radius: CGFloat = 0) {
        layer.borderColor = color?.cgColor
        layer.borderWidth = width
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func setCornerRadius(radius: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize = .zero, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        layer.shouldRasterize = false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 2
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func shake(duration: Double = 0.075, repeatCount: Float = 4) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y - 2))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + 2))
        self.layer.add(animation, forKey: "position")
    }
    
    func viewTouched(duration: TimeInterval = 0.1, completion: @escaping EmptyBlock) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.94)
        }, completion: { _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: { _ in
                completion()
            })
        })
    }
    
    func saveAsImage(scale: CGFloat = 0.0, opaque: Bool = false) -> UIImage? {
        let image = self.asImage()
    
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        imageLayer.contents = image.cgImage
        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = 0.0
        imageLayer.borderWidth = 0.0
        imageLayer.backgroundColor = UIColor.clear.cgColor
        
        UIGraphicsBeginImageContextWithOptions(image.size, opaque, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageLayer.render(in: context)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

