//
//  SignatureColorModel.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

enum SignatureColorModel: String, CaseIterable {
    case black = "black"
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case red = "red"
    
    var isActive: Bool {
        switch self {
        case .purple:
            return false
        default:
            return true
        }
    }
    
    static func signatureColorFor(_ value: String) -> SignatureColorModel? {
        guard let model = SignatureColorModel.allCases.filter({ $0.rawValue == value }).first else { return nil }
        return model
    }
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor(red: 0.333, green: 0.29, blue: 0.941, alpha: 1)
        case .green:
            return UIColor(red: 0.081, green: 0.667, blue: 0.174, alpha: 1)
        case .black:
            return UIColor(red: 0.016, green: 0.008, blue: 0.114, alpha: 1)
        case .red:
            return UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        case .purple:
            return .appSystemColor60
        }
    }
    
    var cgColor: CGColor {
        return color.cgColor
    }
}
