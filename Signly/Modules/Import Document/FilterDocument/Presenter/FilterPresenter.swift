//
//  FilterPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol FilterViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class FilterPresenter: BasePresenter {
    
    weak var view: FilterViewInput?
    
    private var appDataService: AppDataServiceProtocol
    private var page: UIImage
    
    init(page: UIImage, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.page = page
    }
}

extension FilterPresenter: FilterViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(page: page)
    }
}

