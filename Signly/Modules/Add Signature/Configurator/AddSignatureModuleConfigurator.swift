//
//  AddSignatureModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import Foundation

final class AddSignatureModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(type: DrawTypeModel, model: SignatureModel?) -> AddSignatureViewController {
        let controller: AddSignatureViewController = AddSignatureViewController.loadFromNib()
        let presenter = AddSignaturePresenter(type: type, model: model)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
