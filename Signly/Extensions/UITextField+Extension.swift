//
//  UITextField+Extension.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

extension UITextField {
    
    func setClearButtonImage() {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .center
        
        button.setImage(UIImage(named: "clear-button"), for: .highlighted)
        button.setImage(UIImage(named: "clear-button"), for: .normal)
        
        button.frame = CGRect(x: bounds.width - 24, y: (bounds.height - 24) / 2, width: 24, height: 24)
        button.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        
        rightView = button
        rightViewMode = .always
    }
    
    @objc func clearAction() {
        guard let button = rightView as? UIButton else { return }
        
        button.viewTouched {
            self.text = nil
            self.becomeFirstResponder()
        }
    }
}
