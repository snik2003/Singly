//
//  InstructionPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol InstructionViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class InstructionPresenter: BasePresenter {
    
    weak var view: InstructionViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension InstructionPresenter: InstructionViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}
