//
//  CropViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 17.09.2022.
//

import UIKit
import Vision

class CropViewController: BaseViewController {

    private let radius: CGFloat = 10
    private let radius2: CGFloat = 8
    private let maxScale: CGFloat = 3
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var fadeView: UIImageView!
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var pageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: PreviewViewController?
    
    var originalImage: UIImage!
    
    var points: [CGPoint] = []
    var autoPoints: [CGPoint] = []
    var middlePoints: [CGPoint] = []
    
    var pointViews: [UIView] = []
    var middleViews: [UIView] = []
    var maskView: UIView!
    
    var shiftX: CGFloat = 0
    var shiftY: CGFloat = 0
    
    var rotationAngle: CGFloat = 0
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState(image: originalImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addSelection()
        for view in pointViews { view.shake(duration: 0.1, repeatCount: 10) }
    }
    
    @IBAction func closeButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cropButtonAction() {
        guard let delegate = delegate else { return }
        guard let image = cropImage(scale: maxScale) else { return }
        
        cropButton.viewTouched {
            delegate.pageView.image = image
            delegate.document.pages[delegate.selectedPage] = image
            self.closeButtonAction()
        }
    }
    
    func setupInitialState(image: UIImage) {
        pageView.image = image
        pageView.isUserInteractionEnabled = false
        updatePageViewBounds(image: image)
        
        nameLabel.text = "crop.screen.header.label.title".localized()
        nameLabel.textColor = .appDarkTextColor
        nameLabel.font = .appHeadline2
        
        cropButton.setTitle("crop.screen.crop.button.title".localized(), for: .normal)
        cropButton.setTitleColor(.appSystemColor, for: .normal)
        cropButton.titleLabel?.font = .appHeadline3
        
        hintLabel.text = "crop.screen.hint.label.title".localized()
        hintLabel.textColor = .appDarkTextColor
        hintLabel.font = .appHeadline3
        
        addPanGestureToFadeView()
        //addRotationGestureToFadeView()
    }
    
    func addSelection() {
        guard firstAppear else { return }
        firstAppear = false
        
        showLoading()
        ImageProcessor.detectRectangleIn(originalImage, forSize: pageView.bounds.size, shiftX: shiftX, shiftY: shiftY) { points in
            DispatchQueue.main.async {
                self.hideLoading()
            
                guard let points = points else {
                    self.addManualSelection()
                    return
                }
                    
                self.autoPoints = points
                self.addAutoSelection()
            }
        }
    }
    
    func addManualSelection() {
        points.removeAll()
        points.append(CGPoint(x: shiftX, y: shiftY))
        points.append(CGPoint(x: pageViewWidthConstraint.constant + shiftX, y: shiftY))
        points.append(CGPoint(x: pageViewWidthConstraint.constant + shiftX, y: pageViewHeightConstraint.constant + shiftY))
        points.append(CGPoint(x: shiftX, y: pageViewHeightConstraint.constant + shiftY))
        
        addPointViews(points)
        updateFadeView()
    }
    
    func addAutoSelection() {
        points = autoPoints
        addPointViews(points)
        updateFadeView()
    }
    
    func updatePageViewBounds(image: UIImage) {
        
        let ratio = image.size.width / image.size.height
        
        if ratio > 1 {
            pageViewWidthConstraint.constant = UIScreen.main.bounds.width - 60
            pageViewHeightConstraint.constant = pageViewWidthConstraint.constant / ratio
            
            while pageViewHeightConstraint.constant > UIScreen.main.bounds.height - 340 {
                pageViewWidthConstraint.constant -= 5
                pageViewHeightConstraint.constant = pageViewWidthConstraint.constant / ratio
            }
            
        } else if ratio < 1 {
            pageViewHeightConstraint.constant = UIScreen.main.bounds.height - 340
            pageViewWidthConstraint.constant = pageViewHeightConstraint.constant * ratio
            
            while pageViewWidthConstraint.constant > UIScreen.main.bounds.width - 60 {
                pageViewHeightConstraint.constant -= 5
                pageViewWidthConstraint.constant = pageViewHeightConstraint.constant * ratio
            }
        } else {
            pageViewWidthConstraint.constant = UIScreen.main.bounds.width - 60
            pageViewHeightConstraint.constant = UIScreen.main.bounds.width - 60
        }
        
        shiftX = 30 + (UIScreen.main.bounds.width - 60 - pageViewWidthConstraint.constant) / 2
        shiftY = 30 + (UIScreen.main.bounds.height - 340 - pageViewHeightConstraint.constant) / 2
    }
}

extension CropViewController {
    
    func addPointViews(_ points: [CGPoint]) {
        removePointViews()
    
        for index in 1 ... points.count {
            let view = createPointView(in: points[index - 1], index: index)
            addPanGestureTo(view)
            pointViews.append(view)
            fadeView.addSubview(view)
        }
        
        addMiddleViews()
    }
    
    func addMiddleViews() {
        for view in middleViews { view.removeFromSuperview() }
        middleViews.removeAll()
        middlePoints.removeAll()
        
        for index in 1 ... points.count {
            let point2 = index < points.count ? points[index] : points[0]
            let view = createMiddleView(between: points[index - 1], and: point2, index: index)
            addPanGestureTo(view)
            middleViews.append(view)
            fadeView.addSubview(view)
        }
    }
    
    func removePointViews() {
        for view in pointViews { view.removeFromSuperview() }
        pointViews.removeAll()
    }
    
    func createPointView(in point: CGPoint, index: Int) -> UIView {
        let view = UIView()
        view.tag = index
        view.backgroundColor = .appSystemColor
        view.layer.borderWidth = 0.3
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 2 * radius, height: 2 * radius))
        view.center = point
        return view
    }
    
    func createMiddleView(between point1: CGPoint, and point2: CGPoint, index: Int) -> UIView {
        
        let point = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
        middlePoints.append(point)
        
        let view = UIView()
        view.tag = -index
        view.backgroundColor = .appSystemColor
        view.layer.borderWidth = 0.3
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        view.layer.cornerRadius = radius2
        view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 2 * radius2, height: 2 * radius2))
        view.center = point
        return view
    }
    
    func addPanGestureTo(_ view: UIView) {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panRecognized))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
    }
    
    func addPanGestureToFadeView() {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panRecognized2))
        fadeView.isUserInteractionEnabled = true
        fadeView.addGestureRecognizer(pan)
    }
    
    func addRotationGestureToFadeView() {
        let rotation = UIRotationGestureRecognizer()
        rotation.addTarget(self, action: #selector(rotateRecognized))
        fadeView.addGestureRecognizer(rotation)
    }
    
    @objc func panRecognized(_ gestureRecognizer : UIPanGestureRecognizer) {
            
        guard let view = gestureRecognizer.view else { return }
        let index = abs(view.tag)
        
        if view.tag > 0 {
            let point = points[index - 1]
            
            let translation = gestureRecognizer.translation(in: view)
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                
                guard point.x + translation.x >= shiftX - radius else { return }
                guard point.y + translation.y >= shiftY - radius else { return }
                
                guard point.x + translation.x <= pageViewWidthConstraint.constant + shiftX + radius else { return }
                guard point.y + translation.y <= pageViewHeightConstraint.constant + shiftY + radius else { return }
                
                let transform = view.transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
                
                points[index - 1] = CGPoint(x: points[index - 1].x + translation.x, y: points[index - 1].y + translation.y)
                addMiddleViews()
                updateFadeView()
                gestureRecognizer.setTranslation(CGPoint.zero, in: view)
            }
        } else if view.tag < 0 {
            let point1 = points[index - 1]
            let point2 = index < points.count ? points[index] : points[0]
            
            let translation = gestureRecognizer.translation(in: view)
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                
                guard point1.x + translation.x >= shiftX - radius else { return }
                guard point1.y + translation.y >= shiftY - radius else { return }
                
                guard point1.x + translation.x <= pageViewWidthConstraint.constant + shiftX + radius else { return }
                guard point1.y + translation.y <= pageViewHeightConstraint.constant + shiftY + radius else { return }
                
                guard point2.x + translation.x >= shiftX - radius else { return }
                guard point2.y + translation.y >= shiftY - radius else { return }
                
                guard point2.x + translation.x <= pageViewWidthConstraint.constant + shiftX + radius else { return }
                guard point2.y + translation.y <= pageViewHeightConstraint.constant + shiftY + radius else { return }
                
                let transform1 = pointViews[index - 1].transform.translatedBy(x: translation.x, y: translation.y)
                pointViews[index - 1].transform = transform1
                
                points[index - 1] = CGPoint(x: points[index - 1].x + translation.x, y: points[index - 1].y + translation.y)
                
                if index < points.count {
                    let transform2 = pointViews[index].transform.translatedBy(x: translation.x, y: translation.y)
                    pointViews[index].transform = transform2
                    
                    points[index] = CGPoint(x: points[index].x + translation.x, y: points[index].y + translation.y)
                } else {
                    let transform2 = pointViews[0].transform.translatedBy(x: translation.x, y: translation.y)
                    pointViews[0].transform = transform2
                    
                    points[0] = CGPoint(x: points[0].x + translation.x, y: points[0].y + translation.y)
                }
                
                for index in 1 ... points.count {
                    let point1 = points[index - 1]
                    let point2 = index < points.count ? points[index] : points[0]
                    middlePoints[index - 1] = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
                    middleViews[index - 1].center = middlePoints[index - 1]
                }
                
                updateFadeView()
                gestureRecognizer.setTranslation(CGPoint.zero, in: view)
            }
        }
    }
    
    @objc func panRecognized2(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let point = gestureRecognizer.location(in: view)
        
        for view in pointViews { if view.bounds.contains(point) { return } }
        for view in middleViews { if view.bounds.contains(point) { return } }
        
        let translation = gestureRecognizer.translation(in: view)
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            guard point.x > min(points[0].x, points[3].x) && point.y > min(points[0].y, points[1].y) else { return }
            guard point.x < max(points[1].x, points[2].x) && point.y < max(points[2].y, points[3].y) else { return }
            
            guard min(points[0].x, points[3].x) + translation.x >= shiftX - radius else { return }
            guard min(points[0].y, points[1].y) + translation.y >= shiftY - radius else { return }
            
            guard max(points[1].x, points[2].x) + translation.x <= pageViewWidthConstraint.constant + shiftX + radius else { return }
            guard max(points[2].y, points[3].y) + translation.y <= pageViewHeightConstraint.constant + shiftY + radius else { return }
            
            points[0] = CGPoint(x: points[0].x + translation.x, y: points[0].y + translation.y)
            points[1] = CGPoint(x: points[1].x + translation.x, y: points[1].y + translation.y)
            points[2] = CGPoint(x: points[2].x + translation.x, y: points[2].y + translation.y)
            points[3] = CGPoint(x: points[3].x + translation.x, y: points[3].y + translation.y)
            
            let transform0 = pointViews[0].transform.translatedBy(x: translation.x, y: translation.y)
            pointViews[0].transform = transform0
            let transform1 = pointViews[1].transform.translatedBy(x: translation.x, y: translation.y)
            pointViews[1].transform = transform1
            let transform2 = pointViews[2].transform.translatedBy(x: translation.x, y: translation.y)
            pointViews[2].transform = transform2
            let transform3 = pointViews[3].transform.translatedBy(x: translation.x, y: translation.y)
            pointViews[3].transform = transform3
        }
        
        addPointViews(points)
        updateFadeView()
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func rotateRecognized(_ gestureRecognizer : UIRotationGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let point = gestureRecognizer.location(in: view)
        
        for view in pointViews { if view.bounds.contains(point) { return } }
        for view in middleViews { if view.bounds.contains(point) { return } }
        
        let angle = gestureRecognizer.rotation * CGFloat.pi / 180
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            for index in 0 ..< points.count {
                let x = (points[index].x) * cos(angle) - (points[index].y) * sin(angle)
                let y = (points[index].x) * sin(angle) + (points[index].y) * cos(angle)
                points[index] = CGPoint(x: x, y: y)
            }
            
            addMiddleViews()
            updateFadeView()
        }
    }
    
    func maskPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        if middlePoints.count == points.count {
            path.move(to: CGPoint(x: points[0].x + radius, y: points[0].y))
            
            path.addLine(to: CGPoint(x: middlePoints[0].x - radius2, y: middlePoints[0].y))
            path.addArc(withCenter: middlePoints[0], radius: radius2, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
            
            path.addLine(to: CGPoint(x: points[1].x - radius, y: points[1].y))
            path.addArc(withCenter: points[1], radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
            
            path.addLine(to: CGPoint(x: middlePoints[1].x, y: middlePoints[1].y - radius2))
            path.addArc(withCenter: middlePoints[1], radius: radius2, startAngle: -CGFloat.pi / 2, endAngle: -3 * CGFloat.pi / 2,
                        clockwise: false)
            
            path.addLine(to: CGPoint(x: points[2].x, y: points[2].y - radius))
            path.addArc(withCenter: points[2], radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi, clockwise: false)
            
            path.addLine(to: CGPoint(x: middlePoints[2].x + radius2, y: middlePoints[2].y))
            path.addArc(withCenter: middlePoints[2], radius: radius2, startAngle: 0, endAngle: -CGFloat.pi, clockwise: false)
            
            path.addLine(to: CGPoint(x: points[3].x + radius, y: points[3].y))
            path.addArc(withCenter: points[3], radius: radius, startAngle: 0, endAngle: -CGFloat.pi / 2, clockwise: false)
            
            path.addLine(to: CGPoint(x: middlePoints[3].x, y: middlePoints[3].y + radius2))
            path.addArc(withCenter: middlePoints[3], radius: radius2, startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2,
                        clockwise: false)
            
            path.addLine(to: CGPoint(x: points[0].x, y: points[0].y + radius))
            path.addArc(withCenter: points[0], radius: radius, startAngle: CGFloat.pi / 2, endAngle: 0, clockwise: false)
        } else {
            path.move(to: CGPoint(x: points[0].x + radius, y: points[0].y))
            
            path.addLine(to: CGPoint(x: points[1].x - radius, y: points[1].y))
            path.addArc(withCenter: points[1], radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
        
            path.addLine(to: CGPoint(x: points[2].x, y: points[2].y - radius))
            path.addArc(withCenter: points[2], radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi, clockwise: false)
            
            path.addLine(to: CGPoint(x: points[3].x + radius, y: points[3].y))
            path.addArc(withCenter: points[3], radius: radius, startAngle: 0, endAngle: -CGFloat.pi / 2, clockwise: false)
            
            path.addLine(to: CGPoint(x: points[0].x, y: points[0].y + radius))
            path.addArc(withCenter: points[0], radius: radius, startAngle: CGFloat.pi / 2, endAngle: 0, clockwise: false)
        }
        
        path.close()
        
        if abs(middlePoints[0].x - middlePoints[2].x) < 10 {
            let x = middlePoints[0].x - 1.5
            let y = middlePoints[0].y + radius2
            let height = middlePoints[2].y - middlePoints[0].y - 2 * radius2
            let path1 = UIBezierPath(rect: CGRect(x: x, y: y, width: 3.0, height: height))
            path.append(path1)
        }
        
        if abs(middlePoints[1].y - middlePoints[3].y) < 10 {
            let x = middlePoints[3].x + radius2
            let y = middlePoints[3].y - 1.5
            let width = middlePoints[1].x - middlePoints[3].x - 2 * radius2
            let path1 = UIBezierPath(rect: CGRect(x: x, y: y, width: width, height: 3.0))
            path.append(path1)
        }
        
        path.append(UIBezierPath(rect: fadeView.bounds))
        UIColor.clear.setFill()
        path.fill()
        
        return path
    }
    
    func updateFadeView() {
        let path = maskPath()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillRule = .evenOdd
        
        fadeView.layer.mask = mask
        fadeView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        fadeView.drawCropperByPoints(points, middlePoints: middlePoints, cgColor: UIColor.appSystemColor.cgColor)
        
        for view in pointViews { fadeView.bringSubviewToFront(view) }
        for view in middleViews { fadeView.bringSubviewToFront(view) }
    }
    
    func pointsForCropping(scale: CGFloat) -> [CGPoint] {
        var cropPoints: [CGPoint] = []
        
        cropPoints.append(CGPoint(x: (points[0].x - shiftX) * scale, y: (points[0].y - shiftY) * scale))
        cropPoints.append(CGPoint(x: (points[1].x - shiftX) * scale, y: (points[1].y - shiftY) * scale))
        cropPoints.append(CGPoint(x: (points[2].x - shiftX) * scale, y: (points[2].y - shiftY) * scale))
        cropPoints.append(CGPoint(x: (points[3].x - shiftX) * scale, y: (points[3].y - shiftY) * scale))
        
        return cropPoints
    }
    
    func cropImage(scale: CGFloat = 1) -> UIImage? {
        
        let points = pointsForCropping(scale: scale)
        let path = UIBezierPath()
        
        path.move(to: points[0])
        for index in 1 ..< points.count {
            path.addLine(to: index == points.count ? points[0] : points[index])
        }
        
        path.close()
        UIColor.clear.setFill()
        path.fill()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        
        let imageView = UIImageView()
        imageView.clipsToBounds = false
        imageView.image = originalImage
        imageView.frame = CGRect(x: 0, y: 0, width: pageView.bounds.width * scale, height: pageView.bounds.height * scale)
        imageView.layer.mask = shapeLayer
        
        let boundingBox = path.cgPath.boundingBox
        
        UIGraphicsBeginImageContext(boundingBox.size)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: -boundingBox.origin.x, y: -boundingBox.origin.y)
        imageView.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
