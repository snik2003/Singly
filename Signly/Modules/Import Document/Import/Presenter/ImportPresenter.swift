//
//  ImportPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol ImportViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class ImportPresenter: BasePresenter {
    
    weak var view: ImportViewInput?
    private var appDataService: AppDataServiceProtocol
    private var document: DocumentModel?
    
    init(document: DocumentModel?, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.document = document
    }
}

extension ImportPresenter: ImportViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(document: document)
    }
}

