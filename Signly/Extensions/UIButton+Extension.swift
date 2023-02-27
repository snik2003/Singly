//
//  UIButton+Extension.swift
//  CDL
//
//  Created by Сергей Никитин on 08.08.2022.
//

import UIKit

extension UIButton {
    
    open override func awakeFromNib() {
        self.setTitle("", for: .normal)
        super.awakeFromNib()
    }
}
