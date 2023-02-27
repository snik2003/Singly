//
//  CustomAlertController.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import IQKeyboardManager

enum CustomTypeAlertEnum {
    case alertWithTitleAndMessage
    case alertWithErrorMessage
    case alertWithYesAndNo
    case alertWithDoubleActions
    case alertWithThreeActions
    case alertWithoutMessageView
    case alertWithTextField
}

enum CustomTypeButtonAlertEnum {
    case cancel
    case destructive
    case ok
    case standart
}

class CustomAlertController: UIViewController {

    private let redColor = UIColor(red: 0.949, green: 0.263, blue: 0.169, alpha: 1)
    private var header: String? = ""
    private var message: String = ""
    
    private var textFieldValue: String?
    private var textFieldPlaceholder: String?
    private var textFieldKeyboardType: UIKeyboardType?
    
    private var customActionName: String = ""
    private var cancelActionName: String = ""
    private var okActionName: String = ""
    private var action1Name: String = ""
    private var action2Name: String = ""
    
    private var customActionColor: UIColor!
    private var cancelActionColor: UIColor!
    private var okActionColor: UIColor!
    private var action1Color: UIColor!
    private var action2Color: UIColor!

    var customActionButtonType: CustomTypeButtonAlertEnum = .standart
    var cancelActionButtonType: CustomTypeButtonAlertEnum = .standart
    var okActionButtonType: CustomTypeButtonAlertEnum = .standart
    var action1ButtonType: CustomTypeButtonAlertEnum = .standart
    var action2ButtonType: CustomTypeButtonAlertEnum = .standart
    
    private var customActionCompletion: EmptyBlock = {}
    private var cancelActionCompletion: EmptyBlock = {}
    private var okActionCompletion: EmptyBlock = {}
    private var action1Completion: EmptyBlock = {}
    private var action2Completion: EmptyBlock = {}
    private var textFieldCompletion: EditValueBlock = { _ in }
    
    private var typeAlert: CustomTypeAlertEnum = .alertWithErrorMessage
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var customActionView: UIView!
    @IBOutlet weak var cancelActionView: UIView!
    @IBOutlet weak var okActionView: UIView!
    @IBOutlet weak var action1View: UIView!
    @IBOutlet weak var action2View: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var customActionLabel: UILabel!
    @IBOutlet weak var cancelActionLabel: UILabel!
    @IBOutlet weak var okActionLabel: UILabel!
    @IBOutlet weak var action1Label: UILabel!
    @IBOutlet weak var action2Label: UILabel!
    
    @IBOutlet weak var customActionButton: UIButton!
    @IBOutlet weak var cancelActionButton: UIButton!
    @IBOutlet weak var okActionButton: UIButton!
    @IBOutlet weak var action1Button: UIButton!
    @IBOutlet weak var action2Button: UIButton!
    
    @IBOutlet weak var customActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var okActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var okActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var cancelButtonActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonActionTrailingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelLabelActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelLabelActionTrailingConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var okButtonActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okButtonActionTrailingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okLabelActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okLabelActionTrailingConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabelTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var messageLabelTopConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        mainView.backgroundColor = .clear
        mainView.alpha = 0.0
        
        messageView.layer.cornerRadius = 12
        okActionView.layer.cornerRadius = 12
        cancelActionView.layer.cornerRadius = 12
        customActionView.layer.cornerRadius = 12
        
        action1View.layer.cornerRadius = 12
        action2View.layer.cornerRadius = 12
        
        messageView.backgroundColor = .appSystemColor
        okActionView.backgroundColor = .appSystemColor
        action1View.backgroundColor = .appSystemColor
        action2View.backgroundColor = .appSystemColor
        cancelActionView.backgroundColor = .appSystemColor
        customActionView.backgroundColor = .appSystemColor
        
        if typeAlert != .alertWithTextField {
            textField.alpha = 0.0
            textFieldTopConstraint.constant = 0
            textFieldHeightConstraint.constant = 0
        }
        
        if let title = header {
            titleLabel.text = title
            titleLabel.textColor = .white
            titleLabel.font = .appHeadline2
            titleLabelHeightConstaint.isActive = false
            messageLabelTopConstaint.constant = 10
        } else {
            titleLabel.text = ""
            titleLabelHeightConstaint.isActive = true
            messageLabelTopConstaint.constant = 0
        }
        
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = .appSmallBodyText
        updateMessageLabel()
        
        setStyle(customActionButtonType, for: customActionLabel)
        setStyle(cancelActionButtonType, for: cancelActionLabel)
        setStyle(okActionButtonType, for: okActionLabel)
        setStyle(action1ButtonType, for: action1Label)
        setStyle(action2ButtonType, for: action2Label)
        
        if typeAlert == .alertWithTextField {
            
            textField.backgroundColor = .appSystemColor30
            textField.text = textFieldValue
            textField.textColor = .appSystemColor
            textField.tintColor = .appSystemColor
            textField.font = .appHeadline3
            textField.alpha = 1.0
            
            //textField.setClearButtonImage()
            textField.clearButtonMode = .never
            textField.delegate = self
            
            customActionLabel.text = "";
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 0;
            
            cancelActionLabel.text = "";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 0;
            
            okActionLabel.text = "";
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 0;
            
            action1Label.text = action1Name
            action2Label.text = action2Name
            doubleActionViewTopConstraint.constant = 4
            doubleActionViewHeightConstraint.constant = 50
            
            if let keyboardType = textFieldKeyboardType {
                textField.keyboardType = keyboardType
            }
            
            if let placeholder = textFieldPlaceholder {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.paragraphStyle: style,
                    NSAttributedString.Key.foregroundColor: UIColor.appDarkTextColor60,
                    NSAttributedString.Key.font : UIFont.appSmallSemiboldBodyText
                ]
                
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
            } else {
                textField.placeholder = ""
            }
            
        } else if (typeAlert == .alertWithTitleAndMessage) {
            
            customActionLabel.text = ""
            customActionViewTopConstraint.constant = 0
            customActionViewHeightConstraint.constant = 0
            
            cancelActionLabel.text = ""
            cancelActionViewTopConstraint.constant = 0
            cancelActionViewHeightConstraint.constant = 0
            
            okActionLabel.text = okActionName
            okActionViewTopConstraint.constant = 4
            okActionViewHeightConstraint.constant = 50
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == .alertWithErrorMessage) {
            
            customActionLabel.text = ""
            customActionViewTopConstraint.constant = 0
            customActionViewHeightConstraint.constant = 0
            
            cancelActionLabel.text = cancelActionName
            cancelActionViewTopConstraint.constant = 0
            cancelActionViewHeightConstraint.constant = 60
            
            okActionLabel.text = "";
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 0;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == .alertWithYesAndNo) {
            
            customActionLabel.text = ""
            customActionViewTopConstraint.constant = 0
            customActionViewHeightConstraint.constant = 0
            
            cancelActionLabel.text = cancelActionName
            cancelActionViewTopConstraint.constant = 4
            cancelActionViewHeightConstraint.constant = 50
            
            okActionLabel.text = okActionName
            okActionViewTopConstraint.constant = 4
            okActionViewHeightConstraint.constant = 50
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == .alertWithDoubleActions) {
            
            customActionLabel.text = "";
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 0;
            
            cancelActionLabel.text = "";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 0;
            
            okActionLabel.text = "";
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 0;
            
            action1Label.text = action1Name
            action2Label.text = action2Name
            doubleActionViewTopConstraint.constant = 4
            doubleActionViewHeightConstraint.constant = 50
            
        } else if (typeAlert == .alertWithThreeActions) {
            
            customActionLabel.text = customActionName;
            customActionViewTopConstraint.constant = 4;
            customActionViewHeightConstraint.constant = 50;
            
            cancelActionLabel.text = cancelActionName;
            cancelActionViewTopConstraint.constant = 4;
            cancelActionViewHeightConstraint.constant = 50;
            
            okActionLabel.text = okActionName;
            okActionViewTopConstraint.constant = 4;
            okActionViewHeightConstraint.constant = 50;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == .alertWithoutMessageView) {
            
            messageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            messageView.isHidden = true
            
            cancelActionLabel.text = "Отмена";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 60;
            
            okActionLabel.text = okActionName;
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 60;
            
            if (customActionName != "") {
                customActionLabel.text = customActionName;
                customActionViewTopConstraint.constant = 0;
                customActionViewHeightConstraint.constant = 60;
            } else {
                customActionLabel.text = "";
                customActionViewTopConstraint.constant = 0;
                customActionViewHeightConstraint.constant = 0;
            }
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
        }
        
        if let color = customActionColor {
            customActionView.backgroundColor = color
        }
        
        if let color = cancelActionColor {
            cancelActionView.backgroundColor = color
        }
        
        if let color = okActionColor {
            okActionView.backgroundColor = color
        }
        
        if let color = action1Color {
            action1View.backgroundColor = color
        }
        
        if let color = action2Color {
            action2View.backgroundColor = color
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard typeAlert == .alertWithTextField else { return }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        UIView.transition(with: mainView, duration: 0.2, options: .transitionFlipFromTop, animations: {
            self.mainView.alpha = 1.0
        }, completion: { _ in
            guard self.typeAlert == .alertWithTextField else { return }
            self.textField.becomeFirstResponder()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainViewLeadingConstraint.constant = view.bounds.height < 600 ? 20 : 38
        guard view.bounds.width > view.bounds.height else { return }
        mainViewLeadingConstraint.constant = 0.3 * view.bounds.width
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    @IBAction func customAction(sender: UIButton) {
        customActionView.viewTouched {
            self.view.endEditing(true)
            self.dismissAlert(animated: true, completion: self.customActionCompletion)
        }
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        cancelActionView.viewTouched {
            self.view.endEditing(true)
            self.dismissAlert(animated: true, completion: self.cancelActionCompletion)
        }
    }
    
    @IBAction func okAction(sender: UIButton) {
        okActionView.viewTouched {
            self.view.endEditing(true)
            self.dismissAlert(animated: true, completion: self.okActionCompletion)
        }
    }
    
    @IBAction func action1(sender: UIButton) {
        action1View.viewTouched {
            self.view.endEditing(true)
            self.dismissAlert(animated: true, completion: self.action1Completion)
        }
    }
    
    @IBAction func action2(sender: UIButton) {
        action2View.viewTouched {
            self.view.endEditing(true)
            
            guard self.typeAlert == .alertWithTextField, let textFieldValue = self.textFieldValue else {
                self.dismissAlert(animated: true, completion: self.action2Completion)
                return
            }
                
            self.dismissAlert(animated: true, completion: {
                guard let newValue = self.textField.text else { self.textFieldCompletion(textFieldValue); return }
                self.textFieldCompletion(newValue)
            })
        }
    }
    
    func dismissAlert(animated: Bool, completion: @escaping EmptyBlock) {
        UIView.transition(with: mainView, duration: 0.2, options: .transitionFlipFromBottom, animations: {
            self.view.backgroundColor = UIColor.clear
            self.mainView.alpha = 0.0
        }, completion: { _ in
            self.dismiss(animated: animated, completion: completion)
        })
    }
    
    private func updateMessageLabel() {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.18
        style.alignment = .center
        let attributtes = [NSAttributedString.Key.paragraphStyle: style]
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributtes)
        messageLabel.sizeToFit()
    }
    
    private func setStyle(_ style: CustomTypeButtonAlertEnum, for label: UILabel) {
        switch style {
        case .cancel:
            label.font = .appHeadline3
            label.textColor = .appDangerousStatusColor
        case .ok:
            label.font = .appHeadline3
            label.textColor = .white
        case .destructive:
            label.font = .appHeadline3
            label.textColor = .appDangerousStatusColor
        case .standart:
            label.font = .appHeadline3
            label.textColor = .white
        }
    }
}

extension CustomAlertController {
    
    func prepareMessageAlert(title: String? = nil, message: String, actionTitle: String, actionType: CustomTypeButtonAlertEnum,
                             color: UIColor? = nil, completion: @escaping EmptyBlock) {
        
        self.typeAlert = .alertWithTitleAndMessage
                
        self.header = title
        self.message = message
        
        self.okActionCompletion = completion
        self.okActionButtonType = actionType
        self.okActionColor = color
        self.okActionName = actionTitle
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func prepareTwoActionsAlert(title: String? = nil, message: String, title1: String, title2: String,
                                color1: UIColor? = nil, color2: UIColor? = nil,
                                completion1: @escaping EmptyBlock, completion2: @escaping EmptyBlock) {
        
        self.typeAlert = .alertWithYesAndNo
        
        self.header = title
        self.message = message
        
        self.cancelActionCompletion = completion1
        self.cancelActionButtonType = .ok
        self.cancelActionColor = color1
        self.cancelActionName = title1
        
        self.okActionCompletion = completion2
        self.okActionButtonType = .ok
        self.okActionColor = color2
        self.okActionName = title2
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func prepareDoubleActionAlert(title: String? = nil, message: String, okTitle: String, cancelTitle: String,
                                  okColor: UIColor? = nil, cancelColor: UIColor? = nil,
                                  okCompletion: @escaping EmptyBlock, cancelCompletion: @escaping EmptyBlock) {
        
        self.typeAlert = .alertWithDoubleActions
                
        self.header = title
        self.message = message
        
        self.action2Completion = okCompletion
        self.action2ButtonType = .ok
        self.action2Color = okColor
        self.action2Name = okTitle
        
        self.action1Completion = cancelCompletion
        self.action1ButtonType = .cancel
        self.action1Color = cancelColor
        self.action1Name = cancelTitle
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func prepareThreeActionAlert(title: String? = nil, message: String, title1: String, title2: String, title3: String,
                                 color1: UIColor? = nil, color2: UIColor? = nil, color3: UIColor? = nil,
                                 actionType3: CustomTypeButtonAlertEnum = .ok, completion1: @escaping EmptyBlock, completion2: @escaping EmptyBlock, completion3: @escaping EmptyBlock) {
        
        self.typeAlert = .alertWithThreeActions
                
        self.header = title
        self.message = message
        
        self.cancelActionCompletion = completion1
        self.cancelActionButtonType = .ok
        self.cancelActionColor = color1
        self.cancelActionName = title1
        
        self.customActionCompletion = completion2
        self.customActionButtonType = .ok
        self.customActionColor = color2
        self.customActionName = title2
        
        self.okActionCompletion = completion3
        self.okActionButtonType = actionType3
        self.okActionColor = color3
        self.okActionName = title3
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func prepareTextFieldAlert(title: String? = nil, message: String, doneTitle: String, cancelTitle: String,
                               startValue: String, placeholder: String?, keyboardType: UIKeyboardType = .default,
                               completion: @escaping EditValueBlock) {
         
        self.typeAlert = .alertWithTextField
        
        self.textFieldValue = startValue
        self.textFieldPlaceholder = placeholder
        self.textFieldKeyboardType = keyboardType
        
        self.header = title
        self.message = message
         
        self.textFieldCompletion = completion
        self.action2ButtonType = .ok
        self.action2Name = doneTitle
        
        self.action1Completion = {}
        self.action1ButtonType = .cancel
        self.action1Name = cancelTitle
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.mainViewCenterConstraint.constant = -keyboard.height / 2
            self.view.layoutIfNeeded()
        })
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.mainViewCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}

extension CustomAlertController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let position = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        action2(sender: action2Button)
        textField.resignFirstResponder()
        return true
    }
}
