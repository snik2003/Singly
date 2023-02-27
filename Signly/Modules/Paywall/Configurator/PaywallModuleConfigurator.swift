//
//  PaywallModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation

final class PaywallModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> PaywallViewController {
        let controller: PaywallViewController = PaywallViewController.loadFromNib()
        let presenter = PaywallPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
