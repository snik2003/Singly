//
//  AppColors.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit

extension UIColor {
    
    class var appBackgroundColor: UIColor {
        return UIColor(red: 0.973, green: 0.973, blue: 0.98, alpha: 1)
    }
    
    class var appSystemColor: UIColor {
        return UIColor(red: 0.333, green: 0.29, blue: 0.941, alpha: 1)
    }
    
    class var appSystemColor80: UIColor {
        return UIColor(red: 0.467, green: 0.431, blue: 0.953, alpha: 1)
    }
    
    class var appSystemColor60: UIColor {
        UIColor(red: 0.6, green: 0.573, blue: 0.965, alpha: 1)
    }
    
    class var appSystemColor30: UIColor {
        return UIColor(red: 0.8, green: 0.788, blue: 0.984, alpha: 1)
    }
    
    class var appSystemColor10: UIColor {
        return UIColor(red: 0.933, green: 0.929, blue: 0.996, alpha: 1)
    }
    
    class var appDarkTextColor: UIColor {
        return UIColor(red: 0.016, green: 0.008, blue: 0.114, alpha: 1)
    }
    
    class var appDarkTextColor80: UIColor {
        return UIColor(red: 0.212, green: 0.208, blue: 0.29, alpha: 1)
    }
    
    class var appDarkTextColor60: UIColor {
        return UIColor(red: 0.408, green: 0.404, blue: 0.467, alpha: 1)
    }
    
    class var appDarkTextColor30: UIColor {
        return UIColor(red: 0.824, green: 0.824, blue: 0.843, alpha: 1)
    }
    
    class var appDangerousStatusColor: UIColor {
        return UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    class var appGoodStatusColor: UIColor {
        return UIColor(red: 0.081, green: 0.667, blue: 0.174, alpha: 1)
    }
    
    class var appBadStatusColor: UIColor {
        return UIColor(red: 1, green: 0.42, blue: 0, alpha: 1)
    }
    
    class var appAccentButtonColor: UIColor {
        return UIColor(red: 0.129, green: 0.075, blue: 0.91, alpha: 1)
    }
    
    class var appSecondaryButtonColor: UIColor {
        return UIColor(red: 0.886, green: 0.89, blue: 0.894, alpha: 1)
    }
    
    class var appGradientColor1: UIColor {
        return .appSystemColor.withAlphaComponent(0.8)
    }
    
    class var appGradientColor2: UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
    }
}
