//
//  OnboardModel.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation
import UIKit

enum OnboardModel: String, CaseIterable {
    
    case onboard1 = "onboard1"
    case onboard2 = "onboard2"
    case onboard3 = "onboard3"
    case onboard4 = "onboard4"
    
    var numberOfPages: Int {
        return OnboardModel.allCases.count + 1
    }
    
    var pageIndex: Int {
        switch self {
        case .onboard1:
            return 0
        case .onboard2:
            return 1
        case .onboard3:
            return 2
        case .onboard4:
            return 3
        }
    }
    
    var hintText: String {
        return "onboard.screen.\(rawValue).hint.text".localized()
    }
    
    var hintImage: UIImage? {
        return UIImage(named: rawValue)
    }
    
    var hintImageWidth: CGFloat {
        switch self {
        case .onboard1:
            return 294
        case .onboard2:
            return 294
        case .onboard3:
            return 373
        case .onboard4:
            return 294
        }
    }
    
    var hintImageHeight: CGFloat {
        switch self {
        case .onboard1:
            return 344
        case .onboard2:
            return 344
        case .onboard3:
            return 374
        case .onboard4:
            return 344
        }
    }
}
