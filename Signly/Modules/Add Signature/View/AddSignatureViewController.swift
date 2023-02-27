//
//  AddSignatureViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

protocol AddSignatureViewInput: BaseViewInput {
    func setupInitialState(type: DrawTypeModel, model: SignatureModel?)
}

final class AddSignatureViewController: BaseViewController {

    var presenter: AddSignatureViewOutput?
    
    weak var delegate: SigningViewController?
    weak var form: SignatureForm?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: BlueButton!
    @IBOutlet weak var clearButton2: BlueButton!
    @IBOutlet weak var increaseButton: BlueButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    @IBOutlet weak var canvasViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var canvasViewConstraint11: NSLayoutConstraint!
    @IBOutlet weak var canvasViewConstraint12: NSLayoutConstraint!
    @IBOutlet weak var canvasViewConstraint2: NSLayoutConstraint!
    
    var firstAppear = true
    var firstAppear2 = true
    var firstAppear3 = true
    
    var askForClear = false
    var increased = false
    
    var type: DrawTypeModel = .signature
    var model: SignatureModel?
    
    var mouseSwiped = false
    
    var scale: CGFloat = 1
    var startHeight: CGFloat = 0
    
    
    var points: [[CGPoint]] = []
    var sessionPoints: [CGPoint] = []
    var lastPoint: CGPoint!
    
    var penColor: SignatureColorModel = .black
    var dataSource: [SignatureColorModel] = SignatureColorModel.allCases.filter({ $0.isActive })
    
    var brush: SignatureBrushModel = .light
    var dataSource2: [SignatureBrushModel] = SignatureBrushModel.allCases.filter({ $0.isActive })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        checkCanvasViewConstraints()
        getStartHeight()
        getPointsScale()
        addDotterLine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkModel()
    }
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonAction() {
        guard let image = mainImageView.image else { return }
        
        saveButton.viewTouched {
            if let model = self.model {
                if let form = self.form {
                    model.penColor = self.penColor
                    model.points = self.points
                    model.brush = self.brush
                    model.image = image
                    
                    self.navigationController?.popViewController(animated: true) {
                        self.delegate?.showFormWithType(form: form, self.type.toolbarTypeFor, model: model)
                    }
                    
                    return
                }
                
                guard let error = self.presenter?.deleteSignatureModel(model.type) else {
                    model.penColor = self.penColor
                    model.points = self.points
                    model.brush = self.brush
                    model.image = image
                    self.presenter?.saveSignatureModel(model)
                    self.navigationController?.popViewController(animated: true)
                    return 
                }
                
                self.showAttentionMessage(error)
            } else {
                let model = SignatureModel(type: self.type, image: image, points: self.points,
                                           penColor: self.penColor, brush: self.brush)
                
                self.presenter?.saveSignatureModel(model)
                self.navigationController?.popViewController(animated: true) {
                    self.delegate?.showFormWithType(form: self.form, self.type.toolbarTypeFor, model: model)
                }
            }
        }
    }
    
    @IBAction func clearButtonAction() {
        guard mainImageView.image != nil else { return }
        
        clearButton.viewTouched {
            guard self.askForClear else {
                self.clearMainImage()
                return
            }
            
            var message = "add.signature.screen.clear.confirmation.message.text".localized()
            message = message.replacingOccurrences(of: "$DRAW_TYPE$", with: self.type.title.lowercased())
            
            let title1 = "common.yes.button.alert".localized()
            let title2 = "common.cancel.button.alert".localized()
            
            self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
                self.clearMainImage()
            }, comp2: {})
        }
    }
    
    @IBAction func clearButton2Action() {
        guard mainImageView.image != nil else { return }
        
        clearButton2.viewTouched {
            guard self.askForClear else {
                self.clearMainImage()
                return
            }
            
            var message = "add.signature.screen.clear.confirmation.message.text".localized()
            message = message.replacingOccurrences(of: "$DRAW_TYPE$", with: self.type.title.lowercased())
            
            let title1 = "common.yes.button.alert".localized()
            let title2 = "common.cancel.button.alert".localized()
            
            self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
                self.clearMainImage()
            }, comp2: {})
        }
    }
    
    @IBAction func increaseButtonAction() {
        increaseButton.viewTouched {
            self.canvasViewConstraint11.isActive = false
            self.canvasViewConstraint12.isActive = false
            self.canvasViewConstraint2.isActive = false
            
            self.canvasViewHeightConstraint.constant = self.increased ? UIScreen.main.bounds.height - 40 : self.startHeight
            self.canvasViewHeightConstraint.isActive = true
            
            self.removeDotterLine()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.backView.alpha = self.increased ? 0.0 : 1.0
                self.clearButton2.alpha = self.increased ? 0.0 : 1.0
                self.increaseButton.setImage(self.increased ? DrawTypeModel.increaseIcon : DrawTypeModel.reduceIcon, for: .normal)
                self.canvasViewHeightConstraint.constant = self.increased ? self.startHeight : UIScreen.main.bounds.height - 40
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.canvasViewConstraint11.isActive = self.increased
                self.canvasViewConstraint12.isActive = self.increased
                self.canvasViewConstraint2.isActive = !self.increased
                self.canvasViewHeightConstraint.isActive = false
                
                self.firstAppear = true
                self.increased = !self.increased
            })
        }
    }
    
    func onChangeBrushWidth(model: SignatureBrushModel) {
        brush = model
        mainImageView.drawByPoints(points, cgColor: penColor.cgColor, width: brush.width * scale, scale: scale)
        checkSaveButtonEnabledStatus()
        reloadData()
    }
    
    func onChangePenColor(model: SignatureColorModel) {
        penColor = model
        mainImageView.drawByPoints(points, cgColor: penColor.cgColor, width: brush.width * scale, scale: scale)
        checkSaveButtonEnabledStatus()
        reloadData()
    }
}

extension AddSignatureViewController: AddSignatureViewInput {
    
    func setupInitialState(type: DrawTypeModel, model: SignatureModel?) {
        self.type = type
        self.model = model
        
        canvasView.backgroundColor = .white
        canvasView.layer.cornerRadius = 6
        
        if let model = model {
            points = model.points
            penColor = model.penColor
            brush = model.brush
        }
        
        mainImageView.image = nil
        
        clearButton2.alpha = 0.0
        clearButton2.tintColor = .white
        clearButton2.layer.cornerRadius = 6
        
        increaseButton.tintColor = .white
        increaseButton.layer.cornerRadius = 6
        increaseButton.setImage(DrawTypeModel.increaseIcon, for: .normal)
        
        headerLabel.text = type.title
        headerLabel.textColor = .appDarkTextColor
        headerLabel.font = .appHeadline2
        
        saveButton.setTitle("add.signature.screen.save.button.title".localized(), for: .normal)
        saveButton.setTitleColor(.appSystemColor, for: .normal)
        saveButton.titleLabel?.font = .appHeadline3
        checkSaveButtonEnabledStatus()
        
        clearButton.setTitle("add.signature.screen.clear.button.title".localized(), for: .normal)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SignColorCell.self)
        
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.register(SignBrushCell.self)
    }
    
    func checkModel() {
        guard firstAppear3 else { return }
        firstAppear3 = false
        
        mainImageView.drawByPoints(points, cgColor: penColor.cgColor, width: brush.width)
        checkSaveButtonEnabledStatus()
    }
    
    func reloadData() {
        collectionView.reloadData()
        collectionView2.reloadData()
    }
    
    func removeDotterLine() {
        guard let sublayers = canvasView.layer.sublayers, sublayers.count > 0 else { return }
        
        for index in 0 ..< sublayers.count {
            guard let sublayer = sublayers[index] as? CAShapeLayer else { continue }
            sublayer.strokeColor = UIColor.clear.cgColor
            sublayer.removeFromSuperlayer()
        }
    }
    
    func addDotterLine() {
        guard firstAppear else { return }
        firstAppear = false
        
        let dotterLayer = CAShapeLayer()
        dotterLayer.strokeColor = UIColor.appSystemColor30.cgColor
        dotterLayer.lineDashPattern = [4, 2]
        dotterLayer.lineWidth = 3.0
        dotterLayer.frame = canvasView.bounds
        dotterLayer.fillColor = nil
        dotterLayer.path = UIBezierPath(rect: canvasView.bounds).cgPath
        canvasView.layer.addSublayer(dotterLayer)
    }
    
    func getPointsScale() {
        scale = canvasView.bounds.height / startHeight
    }
    
    func getStartHeight() {
        guard firstAppear2 else { return }
        firstAppear2 = false
        startHeight = canvasView.bounds.height
    }
    
    func clearMainImage() {
        sessionPoints.removeAll()
        points.removeAll()
        mainImageView.image = nil
        checkSaveButtonEnabledStatus()
    }
    
    func checkSaveButtonEnabledStatus() {
        saveButton.isEnabled = mainImageView.image != nil
        saveButton.alpha = mainImageView.image != nil ? 1.0 : 0.3
    }
    
    func checkCanvasViewConstraints() {
        let width = startHeight / canvasViewAspectRatioConstraint.multiplier
        let safeAreaLeftInset = view.safeAreaInsets.left
        let safeAreaLeftRight = view.safeAreaInsets.right
        
        guard width > UIScreen.main.bounds.width - safeAreaLeftInset - safeAreaLeftRight - 40 else { return }
        canvasViewAspectRatioConstraint.isActive = false
        canvasViewLeadingConstraint.isActive = true
    }
}

extension AddSignatureViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView { return dataSource.count }
        return dataSource2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            let cell: SignColorCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let model = dataSource[indexPath.item]
            cell.configure(model: model, selected: model == penColor)
            
            return cell
        } else {
            let cell: SignBrushCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let model = dataSource2[indexPath.row]
            cell.configure(model: model, color: penColor.color, selected: model == brush)
            
            return cell
        }
    }
}

extension AddSignatureViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView { return CGSize(width: 40, height: 40) }
        return CGSize(width: dataSource2[indexPath.item].itemWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.collectionView2 {
            let inset = (collectionView.bounds.width - SignatureBrushModel.totalWidth) / 2
            guard inset > 0 else { return UIEdgeInsets.zero }
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }
        
        return UIEdgeInsets.zero
    }
}

extension AddSignatureViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        mouseSwiped = false
        sessionPoints.removeAll()
        
        guard let touch = touches.first else { return }
        lastPoint = touch.location(in: canvasView)
        
        guard canvasView.bounds.contains(lastPoint) else { return }
        sessionPoints.append(CGPoint(x: lastPoint.x / scale, y: lastPoint.y / scale))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        mouseSwiped = true
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: canvasView)
        
        guard canvasView.bounds.contains(currentPoint) else { return }
        sessionPoints.append(CGPoint(x: currentPoint.x / scale, y: currentPoint.y / scale))
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 1)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasView.bounds.width, height: canvasView.bounds.height))
    
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: lastPoint)
        context?.addLine(to: currentPoint)
        context?.setLineCap(.round)
        context?.setLineWidth(brush.width * scale)
        context?.setStrokeColor(penColor.cgColor)
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        mainImageView.alpha = 1.0
        UIGraphicsEndImageContext()
            
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !mouseSwiped {
            UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 1)
            mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasView.bounds.width, height: canvasView.bounds.height))
            
            let context = UIGraphicsGetCurrentContext()
            context?.setLineCap(.round)
            context?.setLineWidth(brush.width * scale)
            context?.setStrokeColor(penColor.color.cgColor)
            context?.setBlendMode(.normal)
            context?.move(to: lastPoint)
            context?.addLine(to: lastPoint)
            context?.strokePath()
            context?.flush()
            
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        points.append(sessionPoints)
        checkSaveButtonEnabledStatus()
    }
}
