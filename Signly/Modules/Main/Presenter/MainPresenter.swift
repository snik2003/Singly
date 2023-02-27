//
//  MainPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

protocol MainViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class MainPresenter: BasePresenter {
    
    weak var view: MainViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension MainPresenter: MainViewOutput {
    
    func viewLoaded() {
        paintbrushSettings()
        view?.setupInitialState()
    }
}
