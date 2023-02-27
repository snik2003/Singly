//
//  SigningToolbarModel.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import Foundation
import UIKit

enum SigningToolbarModel: String, CaseIterable {
    case signature = "signature"
    case initials = "initials"
    case freestyle = "freestyle"
    case text = "text"
    case checkbox = "checkbox"
    case date = "date"
    
    var title: String {
        return "singing.screen.toolbar.\(rawValue).button.title".localized()
    }
    
    var image: UIImage? {
        return UIImage(named: "signing-toolbar-\(rawValue)")
    }
    
    var isActive: Bool {
        return true
    }
    
    var upgradeMessage: String {
        switch self {
        case .signature:
            return "upgrade.view.signature.message.text".localized()
        case .initials:
            return "upgrade.view.initials.message.text".localized()
        case .freestyle:
            return "upgrade.view.freestyle.message.text".localized()
        default:
            return "upgrade.view.additional.message.text".localized()
        }
    }
}
