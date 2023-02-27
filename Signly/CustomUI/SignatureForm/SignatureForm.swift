//
//  SignatureForm.swift
//  Signly
//
//  Created by Сергей Никитин on 08.09.2022.
//

import UIKit
import KDCalendar

class SignatureForm: UIView {

    var formId: String = ""
    var pageIndex: Int!
    
    var delegate: SignatureFormProtocol?
    weak var helper: SigningViewController?
    
    var pointX: CGFloat?
    var pointY: CGFloat?
    
    private var menuView: UIView!
    private var triangleView: UIView!
    
    private var signView: UIView!
    private var signImageView: UIImageView!
    private var sizerView: UIImageView!
    
    var magnifyView: MagnifyView!
    var viewToMagnify: UIView!
    private var magnifyScale: CGFloat = 2.0
    private var isMoving = false
    
    private var collectionView: UICollectionView!
    
    private var menuViewWidth: CGFloat = 0
    private var menuViewHeight: CGFloat = 0
    
    private var triangleViewWidth: CGFloat = 16
    private var triangleViewHeight: CGFloat = 0
    
    private var signViewTop: CGFloat = 0
    var signViewWidth: CGFloat = 80
    var signViewHeight: CGFloat = 40
    
    private var sizerViewWidth: CGFloat = 28
    private var sizerViewHeight: CGFloat = 28
    
    var type: SigningToolbarModel!
    var model: SignatureModel?
    
    var textField: UITextField = UITextField()
    private var textFieldCenterPoint: CGPoint!
    
    var signDate = Date()
    var signText = ""
    var checkbox = CheckboxModel.checkmark
    
    var hasFocus = true
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }
    
    private var dataSource: [SignatureMenuModel] = []
    
    var formWidth: CGFloat {
        return fmax(menuViewWidth, signViewWidth + sizerViewWidth / 2)
    }
    
    var formHeight: CGFloat {
        return menuViewHeight + triangleViewHeight / 2 + signViewTop + signViewHeight + sizerViewHeight / 2
    }
    
    func showForm(in view: UIView, withType type: SigningToolbarModel, andModel model: SignatureModel?) {
        self.type = type
        self.model = model
        self.formId = UUID().uuidString
        
        if type == .text {
            if signText.isEmpty, let name = helper?.presenter?.nameValue() { signText = name }
            if signText.isEmpty, let email = helper?.presenter?.emailValue() { signText = email }
            if signText.isEmpty, let company = helper?.presenter?.companyValue() { signText = company }
            if signText.isEmpty { signText = "Simple Text" }
        }
        
        textField.backgroundColor = .appSystemColor10
        textField.textColor = PaintbrushSettings.shared.color.color
        textField.tintColor = PaintbrushSettings.shared.color.color
        textField.textAlignment = .center
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardAppearance = .light
        textField.returnKeyType = .done
    
        configureView(type: type, model: model)
        createMenuView()
        updateMenuView()
        
        createSignView()
        updateSignView(type: type, model: model)
        
        menuViewUI()
        signViewUI()
        
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: formWidth, height: formHeight)
        
        if pointX == nil || pointY == nil {
            if view.bounds.width > formWidth, view.bounds.height > formHeight {
                pointX = CGFloat.random(in: formWidth / 2 + 10 ... view.bounds.width - formWidth / 2 - 10)
                
                if type == .text || type == .date {
                    pointY = CGFloat.random(in: formHeight / 2 + 10 ... view.bounds.height / 2 - formHeight / 2 - 10)
                } else {
                    pointY = CGFloat.random(in: formHeight / 2 + 10 ... view.bounds.height - formHeight / 2 - 10)
                }
            } else {
                pointX = formWidth / 2 + 10
                pointY = formHeight / 2 + 10
            }
        }
        
        self.center = CGPoint(x: pointX!, y: pointY!)
        self.magnifyScale = fmax(1, viewToMagnify.bounds.width / signViewWidth / 2)
        
        magnifyView = MagnifyView.init(frame: CGRect.zero)
        magnifyView.scale = magnifyScale
        magnifyView.updateBoundsSize(width: signViewWidth)
        magnifyView.commonInit()
        magnifyView.viewToMagnify = viewToMagnify
        magnifyView.setTouchPoint(pt: self.center)
        magnifyView.alpha = 0.0
        
        delegate?.formWasAdded(self, toPage: self.pageIndex)
    }
    
    func configureForm(model: SignatureModel?) {
        self.model = model
        
        guard let model = model else { return }
        signImageView.image = model.image
    }
    
    func prepareForPublish() {
        isUserInteractionEnabled = false
        
        menuView.alpha = 0.0
        sizerView.alpha = 0.0
        triangleView.alpha = 0.0
        
        signView.alpha = 1.0
        signView.backgroundColor = .clear
        signView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func deleteForm() {
        self.lostFocus()
        self.magnifyView.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    private func createMenuView() {
        menuView = UIView()
        triangleView = UIView()
        
        addSubview(triangleView)
        addSubview(menuView)
    }
    
    private func updateMenuView() {
        let x1 = (formWidth - menuViewWidth) / 2
        menuView.frame = CGRect(x: x1, y: 0, width: menuViewWidth, height: menuViewHeight)
        
        let x2 = formWidth / 2 - 8
        triangleView.frame = CGRect(x: x2, y: menuViewHeight - 14, width: triangleViewWidth, height: triangleViewHeight)
    }
    
    private func createSignView() {
        signView = UIView()
        addSubview(signView)
        
        addMoveRecognizer()
        addTapRecognizer()
        createSizerView()
    }
    
    func updateSignView(type: SigningToolbarModel, model: SignatureModel?) {
        
        if type == .date {
            signViewHeight = PaintbrushSettings.shared.size * 3
            signViewWidth = getSignViewWidth(SignatureForm.dateFormatter.string(from: signDate))
            updateMenuView()
            updateSizerView()
        } else if type == .text {
            signViewHeight = PaintbrushSettings.shared.size * 3
            signViewWidth = getSignViewWidth(signText)
            updateMenuView()
            updateSizerView()
        } else if type == .checkbox {
            signViewWidth = signViewHeight
            updateMenuView()
            updateSizerView()
        }
        
        let x = (formWidth - signViewWidth) / 2
        let y = menuViewHeight + triangleViewHeight / 2 + signViewTop
        signView.frame = CGRect(x: x, y: y, width: signViewWidth, height: signViewHeight)
        createSignImageView(model: model)
    }
    
    private func createSignImageView(model: SignatureModel?) {
        signImageView?.removeFromSuperview()
        
        signImageView = UIImageView()
        signImageView.backgroundColor = .clear
        signImageView.frame = signView.bounds
        signView.addSubview(signImageView)
        
        switch type {
        case .signature, .initials, .freestyle:
            guard let model = model else { return }
            signImageView.image = model.image
        case .text:
            signImageView.image = setText(signText)
        case .checkbox:
            signImageView.tintColor = .black
            signImageView.image = checkbox.image
        case .date:
            signImageView.image = setText(SignatureForm.dateFormatter.string(from: signDate))
        case .none:
            break
        }
    }
    
    func prepareBeforeEditTextField() {
        guard type == .text else { return }
        guard let helper = helper else { return }
        guard let superview = superview else { return }
        
        textFieldCenterPoint = CGPoint(x: center.x, y: center.y)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.center = CGPoint(x: superview.bounds.width / 2, y: superview.bounds.height / 4)
            self.selectKeyboardEditingType()
        }, completion: { _ in
            guard !helper.toolbarShown else { return }
            helper.initToolbarView(form: self, textField: self.textField)
        })
    }
    
    func selectKeyboardEditingType() {
        textField.backgroundColor = .appSystemColor10
        textField.frame = CGRect(x: 0, y: 0, width: signViewWidth, height: signViewHeight)
        signView.addSubview(textField)
        
        menuView.alpha = 0.0
        sizerView.alpha = 0.0
        triangleView.alpha = 0.0
        
        signImageView.alpha = 0.0
        textField.alpha = 1.0
    }
    
    func prepareAfterEditTextField(text: String, showMenu: Bool = true) {
        guard type == .text else { return }
        
        menuView.alpha = showMenu ? 1.0 : 0.0
        sizerView.alpha = showMenu ? 1.0 : 0.0
        triangleView.alpha = showMenu ? 1.0 : 0.0
        
        signView.backgroundColor = .appSystemColor10
        signImageView.alpha = 1.0
        textField.alpha = 0.0
        
        signText = text
        textField.removeFromSuperview()
        updateSignView(type: .text, model: nil)
        
        if showMenu {
            magnifyScale = fmax(1, viewToMagnify.bounds.width / signViewWidth / 2)
            magnifyView.scale = magnifyScale
            magnifyView.updateBoundsSize(width: signViewWidth)
            magnifyView.commonInit()
            
            updateMenuView()
            updateSignView(type: .text, model: nil)
            updateSizerView()
            signViewUI()
            magnifyView.setTouchPoint(pt: textFieldCenterPoint)
        
            UIView.animate(withDuration: 0.2, animations: {
                self.bounds.size = CGSize(width: self.formWidth, height: self.formHeight)
                self.center = self.textFieldCenterPoint
            })
        }
    }
    
    func prepareBeforeEditDate() {
        guard type == .date else { return }
        guard let helper = helper else { return }
        guard let superview = superview else { return }
        
        textFieldCenterPoint = CGPoint(x: center.x, y: center.y)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.center = CGPoint(x: superview.bounds.width / 2, y: superview.bounds.height / 4)
            self.selectKeyboardEditingType()
        }, completion: { _ in
            guard !helper.toolbarShown else { return }
            helper.initToolbarView(form: self, textField: self.textField)
        })
    }
    
    func prepareAfterEditDate(showMenu: Bool = true) {
        guard type == .date else { return }
        
        menuView.alpha = showMenu ? 1.0 : 0.0
        sizerView.alpha = showMenu ? 1.0 : 0.0
        triangleView.alpha = showMenu ? 1.0 : 0.0
        
        signView.backgroundColor = .appSystemColor10
        signImageView.alpha = 1.0
        textField.alpha = 0.0
        
        signText = SignatureForm.dateFormatter.string(from: signDate)
        textField.removeFromSuperview()
        updateSignView(type: .date, model: nil)
        
        if showMenu {
            magnifyScale = fmax(1, viewToMagnify.bounds.width / signViewWidth / 2)
            magnifyView.scale = magnifyScale
            magnifyView.updateBoundsSize(width: signViewWidth)
            magnifyView.commonInit()
            
            updateMenuView()
            updateSignView(type: .date, model: nil)
            updateSizerView()
            signViewUI()
            magnifyView.setTouchPoint(pt: textFieldCenterPoint)
        
            UIView.animate(withDuration: 0.2, animations: {
                self.bounds.size = CGSize(width: self.formWidth, height: self.formHeight)
                self.center = self.textFieldCenterPoint
            })
        }
    }
    
    func updateTextField(text: String) {
        signText = text
        signViewWidth = getSignViewWidth(signText)
        
        let x = (formWidth - signViewWidth) / 2
        let y = menuViewHeight + triangleViewHeight / 2 + signViewTop
        signView.frame = CGRect(x: x, y: y, width: signViewWidth, height: signViewHeight)
        textField.frame = CGRect(x: 0, y: 0, width: signViewWidth, height: signViewHeight)
    }
    
    func setText(_ text: String) -> UIImage {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = PaintbrushSettings.shared.currentFont()
        label.textColor = PaintbrushSettings.shared.color.color
        label.textAlignment = .center
        label.text = text
        
        label.frame = signImageView.bounds
        signImageView.addSubview(label)
        
        if PaintbrushSettings.shared.style.contains(.underline) {
            let x = CGFloat(10)
            let y = PaintbrushSettings.shared.size * 2 //+ 0.2 * PaintbrushSettings.shared.size
            let width = signViewWidth - 20
            let height = 0.1 * PaintbrushSettings.shared.size
            
            let underlineView = UIView()
            underlineView.clipsToBounds = true
            underlineView.layer.cornerRadius = height / 2
            underlineView.backgroundColor = PaintbrushSettings.shared.color.color
            underlineView.frame = CGRect(x: x, y: y, width: width, height: height)
            label.addSubview(underlineView)
        }
        
        signImageView.image = nil
        let image = signImageView.asImage()
        label.removeFromSuperview()
        
        return image
    }
    
    private func getSignViewWidth(_ text: String) -> CGFloat {
        
        let font = PaintbrushSettings.shared.currentFont()
        
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font]
        
        return text.boundingRect(with: size, options: options, attributes: attr, context: nil).width + 20
    }
    
    private func createSizerView() {
        sizerView?.removeFromSuperview()
        
        sizerView = UIImageView()
        sizerView.backgroundColor = .clear
        sizerView.image = UIImage(named: "change-sign-size")
        sizerView.clipsToBounds = true
        sizerView.layer.cornerRadius = sizerViewWidth / 2
        addSubview(sizerView)
        
        let x = formWidth / 2 + signViewWidth / 2 - sizerViewWidth / 2
        let y = formHeight - sizerViewHeight
        sizerView.frame = CGRect(x: x, y: y, width: sizerViewWidth, height: sizerViewHeight)
        
        addChangeSizeRecognizer()
    }
    
    private func updateSizerView() {
        let x = formWidth / 2 + signViewWidth / 2 - sizerViewWidth / 2
        let y = formHeight - sizerViewHeight
        sizerView.frame = CGRect(x: x, y: y, width: sizerViewWidth, height: sizerViewHeight)
    }
    
    private func configureView(type: SigningToolbarModel, model: SignatureModel?) {
        
        dataSource = type == .checkbox ? [.checkmark, .crossmark, .roundmark, .divider, .copy, .delete] : [.copy, .edit, .divider, .delete]
        signViewTop = dataSource.count > 0 ? 5 : 0
        
        let activeCount = dataSource.filter({ $0 != .divider }).count
        let dividerCount = dataSource.filter({ $0 == .divider }).count
        
        menuViewWidth = dataSource.count > 0 ? CGFloat(16 + 40 * activeCount + 10 * dividerCount) : 0
        menuViewHeight = dataSource.count > 0 ? 40 : 0
        triangleViewHeight = dataSource.count > 0 ? 28 : 0
    }
    
    private func menuViewUI() {
        guard dataSource.count > 0 else {
            menuView.alpha = 0.0
            triangleView.alpha = 0.0
            menuViewHeight = 0.0
            triangleViewHeight = 0.0
            signViewTop = 0.0
            return
        }
        
        menuView.backgroundColor = isMoving ? .clear : .appDarkTextColor
        menuView.layer.cornerRadius = 12
        triangleView.backgroundColor = isMoving ? .clear : .appDarkTextColor
        triangleView.layer.cornerRadius = 24
        
        menuView.alpha = isMoving ? 0.0 : 1.0
        triangleView.alpha = isMoving ? 0.0 : 1.0
        
        reloadMenuData()
    }
    
    private func signViewUI() {
        signView.backgroundColor = isMoving ? .clear : .appSystemColor.withAlphaComponent(0.1)
        signView.layer.borderWidth = isMoving ? 0.0 : signViewWidth > 150 ? 2.0 : 1.0
        signView.layer.borderColor = isMoving ? UIColor.clear.cgColor : UIColor.appSystemColor.cgColor
        signView.layer.cornerRadius = signViewWidth > 120 ? 12 : signViewWidth > 100 ? 10 : signViewWidth > 80 ? 8 : 6
        
        guard let magnifyView = self.magnifyView else { return }
        magnifyView.deltaY = 0.5 * (menuViewHeight + triangleViewHeight / 2 + signViewTop - sizerViewHeight / 2)
    }
    
    private func addMoveRecognizer() {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panRecognized(_:)))
        signView.isUserInteractionEnabled = true
        signView.addGestureRecognizer(pan)
    }
    
    private func addTapRecognizer() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapRecognized(_:)))
        signView.isUserInteractionEnabled = true
        signView.addGestureRecognizer(tap)
    }
    
    private func addChangeSizeRecognizer() {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panRecognized2(_:)))
        sizerView.isUserInteractionEnabled = true
        sizerView.addGestureRecognizer(pan)
    }
    
    func menuActionFor(_ menuModel: SignatureMenuModel) {
        switch menuModel {
        case .copy:
            helper?.askForCopyForm(comp1: {
                self.delegate?.formNeedCopyInCurrentPage(self)
            }, comp2: {
                self.delegate?.formNeedCopyInAllPages(self)
            })
        case .edit:
            delegate?.formNeedEdit(self, with: self.type)
        case .delete:
            deleteForm()
            delegate?.formWasRemoved(self, fromPage: self.pageIndex)
        case .checkmark:
            onChangeCheckbox(.checkmark)
        case .crossmark:
            onChangeCheckbox(.crossmark)
        case .roundmark:
            onChangeCheckbox(.roundmark)
        default:
            break
        }
    }
}

extension SignatureForm {
    
    func getFocus() {
        hasFocus = true
        menuView.alpha = 1.0
        sizerView.alpha = 1.0
        triangleView.alpha = 1.0
        
        menuView.isUserInteractionEnabled = true
        sizerView.isUserInteractionEnabled = true
        triangleView.isUserInteractionEnabled = true
        
        signViewUI()
        helper?.setNameLabelWhenFormGetFocus(self)
        superview?.bringSubviewToFront(self)
    }
    
    func lostFocus() {
        hasFocus = false
        menuView.alpha = 0.0
        sizerView.alpha = 0.0
        triangleView.alpha = 0.0
        textField.alpha = 0.0
        
        menuView.isUserInteractionEnabled = false
        sizerView.isUserInteractionEnabled = false
        triangleView.isUserInteractionEnabled = false
        
        signView.backgroundColor = UIColor.clear
        signView.layer.borderColor = UIColor.clear.cgColor
        helper?.setNameLabelWhenFormLostFocus()
    }
    
    func hideFormBeforeMoving() {
        isMoving = true
        
        menuView.alpha = 0.0
        sizerView.alpha = 0.0
        triangleView.alpha = 0.0
        signViewUI()
    }
    
    func showFormAfterMoving() {
        isMoving = false
        
        menuView.alpha = 1.0
        sizerView.alpha = 1.0
        triangleView.alpha = 1.0
        signViewUI()
    }
    
    private func movingBegan() {
        helper?.formMovingActive = true
        helper?.setFocusOnForm(self)
        helper?.prepareFormsBeforeMovingForm(self)
        
        isMoving = true
        sizerView.alpha = 0.0
        magnifyView.alpha = 1.0
        
        let center = signView.center
        let width = magnifyScale * signViewWidth
        let height = magnifyScale * signViewHeight
        
        signView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        signImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        signView.center = CGPoint(x: center.x, y: center.y - 80)
        
        menuViewUI()
        signViewUI()
    }
    
    private func movingEnded() {
        helper?.formMovingActive = false
        helper?.prepareFormsAfterMovingForm(self)
        
        isMoving = false
        sizerView.alpha = 1.0
        magnifyView.alpha = 0.0
        
        let center = signView.center
        let width = signViewWidth
        let height = signViewHeight
        
        signView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        signImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        signView.center = CGPoint(x: center.x, y: center.y + 80)
        
        menuViewUI()
        signViewUI()
        
        helper?.setFocusOnForm(self)
    }
    
    @objc
    private func panRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let view = gestureRecognizer.view
        
        guard let superview = superview else { return }
        superview.bringSubviewToFront(self)
        
        let currentPoint = center
        let translation = gestureRecognizer.translation(in: superview)
       
        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            movingEnded()
            return
        }
        
        if gestureRecognizer.state == .began {
            movingBegan()
        }
    
        let newPoint = CGPoint(x: currentPoint.x + translation.x, y: currentPoint.y + translation.y)
        
        guard newPoint.x >= bounds.width / 4 else { return }
        guard newPoint.y >= bounds.height / 4 else { return }
        
        guard newPoint.x <= superview.bounds.width - bounds.width / 4 else { return }
        guard newPoint.y <= superview.bounds.height - bounds.height / 4 else { return }
        
        pointX = newPoint.x
        pointY = newPoint.y
        
        self.center = newPoint
        
        magnifyView.setTouchPoint(pt: newPoint)
        magnifyView.setNeedsDisplay()
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc
    private func panRecognized2(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began { helper?.formMovingActive = true }
        if gestureRecognizer.state == .ended { helper?.formMovingActive = false }
        
        let view = gestureRecognizer.view
        guard let superview = superview else { return }
        
        var currentPoint = center
        let translation = gestureRecognizer.translation(in: superview)
        
        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else { return }
    
        var newWidth: CGFloat = signViewWidth + translation.x
        var newHeight: CGFloat = newWidth / 2
        
        if type == .date {
            newHeight = signViewHeight + translation.y
            newWidth = getSignViewWidth(SignatureForm.dateFormatter.string(from: signDate))
        } else if type == .text {
            newHeight = signViewHeight + translation.y
            newWidth = getSignViewWidth(signText)
        } else if type == .checkbox {
            newHeight = signViewHeight + translation.y
            newWidth = newHeight
        }
        
        if newWidth < 40 { newWidth = 40 }
        if newWidth > superview.bounds.width - 40 { newWidth = superview.bounds.width - 40 }
        
        if currentPoint.x < newWidth / 4 { currentPoint.x = newWidth / 4 }
        if currentPoint.y < newHeight / 4 { currentPoint.y = newHeight / 4 }
        
        if currentPoint.x > superview.bounds.width - newWidth / 4 { currentPoint.x = superview.bounds.width - newWidth / 4 }
        if currentPoint.y > superview.bounds.height - newHeight / 4 { currentPoint.y = superview.bounds.height - newHeight / 4 }
        
        signViewWidth = newWidth
        signViewHeight = newHeight
        
        magnifyScale = fmax(1, viewToMagnify.bounds.width / newWidth / 2)
        magnifyView.scale = magnifyScale
        magnifyView.updateBoundsSize(width: newWidth)
        magnifyView.commonInit()
        
        updateMenuView()
        updateSignView(type: type, model: model)
        updateSizerView()
        signViewUI()
        
        self.bounds.size = CGSize(width: formWidth, height: formHeight)
        self.center = currentPoint
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc
    private func tapRecognized(_ gestureRecognizer: UITapGestureRecognizer) {
        signView.viewTouched {
            UIView.animate(withDuration: 0.4, animations: {
                self.hasFocus ? self.lostFocus() : self.helper?.setFocusOnForm(self)
            })
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            let localPoint = self.convert(point, to: subview)
            if subview.isUserInteractionEnabled, subview.point(inside: localPoint, with: event) { return true }
        }
        
        return false
    }
}

extension SignatureForm: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        signDate = date
        updateSignView(type: type, model: nil)
        
        guard let helper = helper else { return }
        helper.hideCalendarView() {
            helper.monthPicker = 0
            helper.selectedDate = date
            helper.setupCalendarViewStyle()
            helper.calendarView.reloadData()
        }
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {}
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool { return true }
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {}
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {}
}

extension SignatureForm {
    
    func onChangeCheckbox(_ model: CheckboxModel) {
        checkbox = model
        updateSignView(type: type, model: nil)
        
        let indexPath1 = IndexPath(item: 0, section: 0)
        let indexPath2 = IndexPath(item: 1, section: 0)
        let indexPath3 = IndexPath(item: 2, section: 0)
        collectionView.reloadItems(at: [indexPath1, indexPath2, indexPath3])
        
        guard let helper = helper else { return }
        helper.reloadData3()
        helper.hideCheckboxView()
    }
}

extension SignatureForm: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func reloadMenuData() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 32, height: 32)
        
        let frame = CGRect(x: 8, y: 4, width: menuViewWidth - 16, height: menuViewHeight - 8)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SignatureMenuCell.self)
        menuView.addSubview(collectionView)
        
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == helper?.collectionView3 { return CheckboxModel.allCases.count }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == helper?.collectionView3 {
            let cell: SelectCheckboxCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.form = self
            
            let model = CheckboxModel.allCases[indexPath.item]
            cell.configure(model: model, selected: checkbox == model)
            
            return cell
        } else {
            let cell: SignatureMenuCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let model = dataSource[indexPath.item]
            let selected = model == checkbox.menuModel
            cell.configure(model: model, selected: selected)
            
            return cell
        }
    }
}

extension SignatureForm: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         
        if collectionView == helper?.collectionView3 { return CGSize(width: 80, height: 80) }
        if dataSource[indexPath.item] == .divider { return CGSize(width: 2, height: 32) }
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == helper?.collectionView3 {
            let inset = (collectionView.bounds.height - 80) / 2
            return UIEdgeInsets(top: inset, left: 8, bottom: inset, right: 8)
        }
        
        let inset = (collectionView.bounds.height - 32) / 2
        return UIEdgeInsets(top: inset, left: 4, bottom: inset, right: 4)
    }
}
