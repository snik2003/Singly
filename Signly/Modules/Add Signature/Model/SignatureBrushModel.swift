//
//  SignatureBrushModel.swift
//  Signly
//
//  Created by Сергей Никитин on 07.09.2022.
//

import UIKit

enum SignatureBrushModel: String, CaseIterable {
    case light = "light"
    case medium = "medium"
    case semibold = "semibold"
    case bold = "bold"
    case heavy = "heavy"
    
    var isActive: Bool {
        return true
    }
    
    static func signatureBrushFor(_ value: String) -> SignatureBrushModel? {
        guard let model = SignatureBrushModel.allCases.filter({ $0.rawValue == value }).first else { return nil }
        return model
    }
    
    var width: CGFloat {
        switch self {
        case .light:
            return 3
        case .medium:
            return 6
        case .semibold:
            return 9
        case .bold:
            return 12
        case .heavy:
            return 16
        }
    }
    
    var itemWidth: CGFloat {
        switch self {
        case .light:
            return 50
        case .medium:
            return 55
        case .semibold:
            return 55
        case .bold:
            return 60
        case .heavy:
            return 65
        }
    }
    
    static var totalWidth: CGFloat {
        var total: CGFloat = 0
        for brush in allCases.filter({ $0.isActive }) { total += brush.itemWidth }
        return total
    }
}
