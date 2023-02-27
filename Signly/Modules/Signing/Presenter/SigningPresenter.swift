//
//  SigningPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

protocol SigningViewOutput: BaseViewOutput {
    func viewLoaded()
    func documentDate() -> String
}

final class SigningPresenter: BasePresenter {
    
    weak var view: SigningViewInput?
    
    private var appDataService: AppDataServiceProtocol
    private var document: DocumentModel
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm:ss"
        return dateFormatter
    }
    
    init(document: DocumentModel, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.document = document
    }
}

extension SigningPresenter: SigningViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(document: document)
    }
    
    func documentDate() -> String {
        return dateFormatter.string(from: document.createDate)
    }
}
