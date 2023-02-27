//
//  SettingsPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

protocol SettingsViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class SettingsPresenter: BasePresenter {
    
    weak var view: SettingsViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension SettingsPresenter: SettingsViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}

