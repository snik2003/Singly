//
//  SettingsModel.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

enum SettingsModelType {
    case textField
    case disclosureButton
    case custom
}

enum SettingsModel: String, CaseIterable {
    case name = "name"
    case email = "email"
    case company = "company"
    case signature = "signature"
    case initials = "initials"
    case privacy = "privacy"
    case terms = "terms"
    case contact = "contact"
    
    var type: SettingsModelType {
        switch self {
        case .name, .email, .company:
            return .textField
        case .privacy, .terms, .contact:
            return .disclosureButton
        default:
            return .custom
        }
    }
    
    var rowHeight: CGFloat {
        switch self.type {
        case .textField, .disclosureButton:
            return 64
        case .custom:
            return 108
        }
    }
    
    var bottomInset: CGFloat {
        switch self {
        case .name:
            return 76 + 10
        case .email:
            return 76 * 2 + 10
        case .company:
            return 76 * 3 + 10
        default:
            return 0
        }
    }
    
    var title: String {
        return "settings.screen.menu.\(rawValue).title".localized()
    }
    
    var placeholder: String {
        switch self.type {
        case .textField, .custom:
            return "settings.screen.menu.\(rawValue).placeholder".localized()
        default:
            return ""
        }
    }
}
