//
//  PreviewPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol PreviewViewOutput: BaseViewOutput {
    func viewLoaded()
    func documentDate() -> String
}

final class PreviewPresenter: BasePresenter {
    
    weak var view: PreviewViewInput?
    
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

extension PreviewPresenter: PreviewViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(document: document)
    }
    
    func documentDate() -> String {
        return dateFormatter.string(from: document.createDate)
    }
}
