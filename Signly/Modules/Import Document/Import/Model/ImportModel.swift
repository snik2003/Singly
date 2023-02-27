//
//  ImportModel.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import Foundation
import UIKit

enum ImportModel: String, CaseIterable {
    case scan   = "scan"
    case photos = "photos"
    case files  = "files"
    case email  = "email"
    case other  = "other"
    
    var title: String {
        return "import.document.screen.\(rawValue).method.title".localized()
    }
    
    var image: UIImage? {
        return UIImage(named: "\(rawValue)-method")
    }
    
    var isActive: Bool {
        switch self {
        case .scan:
            return UIImagePickerController.isSourceTypeAvailable(.camera)
        default:
            return true
        }
    }
}
