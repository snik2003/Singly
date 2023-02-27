//
//  SignatureMenuModel.swift
//  Signly
//
//  Created by Сергей Никитин on 08.09.2022.
//

import Foundation
import UIKit

enum SignatureMenuModel: String, CaseIterable {
    case copy = "copy"
    case edit = "edit"
    case delete = "delete"
    case checkmark = "checkmark"
    case crossmark = "crossmark"
    case roundmark = "roundmark"
    case divider = "divider"
    
    var icon: UIImage? {
        switch self {
        case .copy, .edit, .delete:
            return UIImage(named: "\(rawValue)-item")
        case .checkmark, .crossmark, .roundmark:
            return UIImage(named: "checkbox-\(rawValue)")
        default:
            return nil
        }
    }
}
