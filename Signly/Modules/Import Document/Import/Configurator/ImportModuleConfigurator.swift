//
//  ImportModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import Foundation

final class ImportModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(document: DocumentModel? = nil) -> ImportViewController {
        let controller: ImportViewController = ImportViewController.loadFromNib()
        let presenter = ImportPresenter(document: document)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
