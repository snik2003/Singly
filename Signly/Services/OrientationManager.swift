//
//  OrientationManager.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

class OrientationManager {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.orientationLock = orientation
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func checkViewControllerForAppearance(_ controller: BaseViewController) {
        guard controller is AddSignatureViewController else { return }
        controller.view.alpha = 1.0
        lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
    }
    
    static func checkViewControllerForDisappearance(_ controller: BaseViewController) {
        guard controller is AddSignatureViewController else { return }
        controller.view.alpha = 0.0
        lockOrientation(.portrait, andRotateTo: .portrait)
    }
}
