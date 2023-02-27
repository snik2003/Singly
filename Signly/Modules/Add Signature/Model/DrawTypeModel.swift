//
//  DrawTypeModel.swift
//  Signly
//
//  Created by Сергей Никитин on 07.09.2022.
//

import UIKit

enum DrawTypeModel: String, CaseIterable {
    case signature = "signature"
    case initials = "initials"
    case freestyle = "freestyle"
    
    var title: String {
        return "add.\(rawValue).screen.header.label.title".localized()
    }
    
    static func drawTypeFor(_ value: String) -> DrawTypeModel? {
        switch value {
        case "signature":
            return .signature
        case "initials":
            return .initials
        case "freestyle":
            return .freestyle
        default:
            return nil
        }
    }
    
    var toolbarTypeFor: SigningToolbarModel {
        switch self {
        case .signature:
            return .signature
        case .initials:
            return .initials
        case .freestyle:
            return .freestyle
        }
    }
    
    static var increaseIcon: UIImage {
        return UIImage(named: "increase-icon")!
    }
    
    static var reduceIcon: UIImage {
        return UIImage(named: "reduce-icon")!
    }
    
    
}
