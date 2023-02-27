//
//  FilterModel.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import Foundation
import UIKit

enum FilterModel: CaseIterable {
    case original
    case blackWhite
    case grayscale
    case contrast
    case brightness
    
    var isActive: Bool {
        switch self {
        case .brightness:
            return false
        default:
            return true
        }
    }
    
    var title: String {
        switch self {
        case .original:
            return "filter.screen.original.filter.label.title".localized()
        case .blackWhite:
            return "filter.screen.black.white.filter.label.title".localized()
        case .grayscale:
            return "filter.screen.grayscale.filter.label.title".localized()
        case .contrast:
            return "filter.screen.contrast.filter.label.title".localized()
        case .brightness:
            return "filter.screen.brightness.filter.label.title".localized()
        }
    }
    
    func image(_ image: UIImage, value: Float? = nil) -> UIImage? {
        switch self {
        case .original:
            return image
        case .blackWhite:
            return image.convertToBlackAndWhite()
        case .grayscale:
            return image.convertToGrayScale()
        case .contrast:
            return image.contrastImage(value: value)
        case .brightness:
            return image.brightnessImage(value: value)
        }
    }
}
