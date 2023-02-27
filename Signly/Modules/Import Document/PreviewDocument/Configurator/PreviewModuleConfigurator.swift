//
//  PreviewModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import Foundation

final class PreviewModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(document: DocumentModel) -> PreviewViewController {
        let controller: PreviewViewController = PreviewViewController.loadFromNib()
        let presenter = PreviewPresenter(document: document)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
