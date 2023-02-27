//
//  KeyboardService.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class KeyboardService: NSObject {
    static var serviceSingleton = KeyboardService()
    
    var measuredSize: CGRect = CGRect.zero
    var duration: TimeInterval = 0.0
    var curve: UInt = 0
    
    @objc class func keyboardHeight() -> CGFloat {
        let keyboardSize = KeyboardService.keyboardSize()
        return keyboardSize.size.height
    }

    @objc class func keyboardSize() -> CGRect {
        return serviceSingleton.measuredSize
    }
    
    @objc class func keyboardAnimationDuration() -> TimeInterval {
        return serviceSingleton.duration
    }
    
    @objc class func keyboardAnimationCurve() -> UInt {
        return serviceSingleton.curve
    }

    private func observeKeyboardNotifications() {
        let center = NotificationCenter.default
        
        center.addObserver(self,
                           selector: #selector(self.keyboardChange),
                           name: UIResponder.keyboardDidShowNotification,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(self.keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification,
                           object: nil)
    }

    private func observeKeyboard() {
        let field = UITextField()
        UIApplication.shared.windows.first?.addSubview(field)
        field.becomeFirstResponder()
        field.resignFirstResponder()
        field.removeFromSuperview()
    }

    @objc private func keyboardChange(_ notification: Notification) {
        guard measuredSize == CGRect.zero, let info = notification.userInfo else { return }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        measuredSize = value.cgRectValue
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard duration == 0.0, curve == 0, let info = notification.userInfo else { return }
        
        if let value = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            duration = TimeInterval(value.doubleValue)
        }
        
        if let value = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            curve = value
        }
    }

    override init() {
        super.init()
        observeKeyboardNotifications()
        observeKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
