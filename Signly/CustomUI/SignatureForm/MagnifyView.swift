//
//  MagnifyView.swift
//  Signly
//
//  Created by Сергей Никитин on 09.09.2022.
//

import UIKit

class MagnifyView: UIView {

    var viewToMagnify: UIView!
    var backView: UIView?
    
    var touchPoint: CGPoint!
    
    var scale: CGFloat = 2.0
    var deltaY: CGFloat = 0.0
    
    var addScale: CGFloat {
        guard bounds.width > 100 else { return 0.5 }
        guard bounds.width > 200 else { return 0.35 }
        guard bounds.width > 300 else { return 0.2}
        return 0.1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.layer.borderColor = UIColor.appSystemColor.cgColor
        self.layer.borderWidth = bounds.width > 100 ? 2.0 : 1.0
        self.layer.cornerRadius = 12 //bounds.width / 2
        self.layer.masksToBounds = true
        
        backView?.removeFromSuperview()
        backView = UIView()
        backView?.frame = self.bounds
        backView?.backgroundColor = UIColor.appSystemColor .withAlphaComponent(0.1)
        self.addSubview(backView!)
    }
    
    func updateBoundsSize(width: CGFloat) {
        let add = self.addScale
        self.bounds.size = CGSize(width: (scale + add) * width, height: (scale + add) * width)
    }
    
    func setTouchPoint(pt: CGPoint) {
        touchPoint = CGPoint(x: pt.x, y: pt.y + deltaY)
        self.center = CGPoint(x: pt.x, y: pt.y + deltaY - 80)
    }
    
    override func draw(_ rect: CGRect) {
        guard let touchPoint = touchPoint else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.translateBy(x: 1 * (self.frame.size.width * 0.5), y: 1 * (self.frame.size.height * 0.5))
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -1 * (touchPoint.x), y: -1 * (touchPoint.y))
        self.viewToMagnify.layer.render(in: context)
    }
}

