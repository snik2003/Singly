//
//  InstructionModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import Foundation

final class InstructionModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> InstructionViewController {
        let controller: InstructionViewController = InstructionViewController.loadFromNib()
        let presenter = InstructionPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
