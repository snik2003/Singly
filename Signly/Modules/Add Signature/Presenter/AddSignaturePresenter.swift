//
//  AddSignaturePresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

protocol AddSignatureViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class AddSignaturePresenter: BasePresenter {
    
    weak var view: AddSignatureViewInput?
    private var appDataService: AppDataServiceProtocol
    private var type: DrawTypeModel
    private var model: SignatureModel?
    
    init(type: DrawTypeModel, model: SignatureModel?, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.model = model
        self.type = type
    }
}

extension AddSignaturePresenter: AddSignatureViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(type: type, model: model)
    }
}

