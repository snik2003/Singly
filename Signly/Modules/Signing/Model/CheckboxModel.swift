//
//  CheckboxModel.swift
//  Signly
//
//  Created by Сергей Никитин on 09.09.2022.
//

import Foundation
import simd
import UIKit

enum CheckboxModel: String, CaseIterable {
    case checkmark = "checkmark"
    case crossmark = "crossmark"
    case roundmark = "roundmark"
    
    var image: UIImage? {
        return UIImage(named: "checkbox-\(rawValue)")
    }
    
    var menuModel: SignatureMenuModel {
        switch self {
        case .checkmark:
            return .checkmark
        case .crossmark:
            return .crossmark
        case .roundmark:
            return .roundmark
        }
    }
}
