//
//  SigningModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import Foundation

final class SigningModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(document: DocumentModel) -> SigningViewController {
        let controller: SigningViewController = SigningViewController.loadFromNib()
        let presenter = SigningPresenter(document: document)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
