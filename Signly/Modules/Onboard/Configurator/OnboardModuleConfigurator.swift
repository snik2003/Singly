//
//  OnboardModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation

final class OnboardModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(onboard: OnboardModel = .onboard1) -> OnboardViewController {
        let controller: OnboardViewController = OnboardViewController.loadFromNib()
        let presenter = OnboardPresenter(onboard: onboard)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
