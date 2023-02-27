//
//  MainModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import Foundation

final class MainModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> MainViewController {
        let controller: MainViewController = MainViewController.loadFromNib()
        let presenter = MainPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
