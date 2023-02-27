//
//  UIView+Reusable.swift
//  CDL
//
//  Created by Сергей Никитин on 05.08.2022.
//

import UIKit

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
