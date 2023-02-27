//
//  FilterModuleConfigurator.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

final class FilterModuleConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(page: UIImage) -> FilterViewController {
        let controller: FilterViewController = FilterViewController.loadFromNib()
        let presenter = FilterPresenter(page: page)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
