//
//  DocumentMenuModel.swift
//  Signly
//
//  Created by Сергей Никитин on 11.09.2022.
//

import Foundation
import UIKit

enum DocumentMenuModel: String, CaseIterable {
    case sign = "sign"
    case share = "share"
    case preview = "preview"
    case rename = "rename"
    case dublicate = "dublicate"
    case delete = "delete"
    
    var isActive: Bool {
        switch self {
            //case .preview:
            //    return false
            default:
                return true
        }
    }
    
    var title: String {
        return "main.screen.document.menu.\(rawValue).item.title".localized()
    }
    
    var icon: UIImage? {
        return UIImage(named: "doc-menu-\(rawValue)")
    }
}
