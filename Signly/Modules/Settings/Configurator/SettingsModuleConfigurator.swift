//
//  SettingsModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import Foundation

final class SettingsModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> SettingsViewController {
        let controller: SettingsViewController = SettingsViewController.loadFromNib()
        let presenter = SettingsPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
