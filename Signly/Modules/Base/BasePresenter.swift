//
//  BasePresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation
import CoreData

protocol BaseViewOutput {
    func isPremium() -> Bool
    func setPremiumMode(_ status: Bool)
    func isFirstSign() -> Bool
    func setupFirstSign()
    func isFirstShare() -> Bool
    func setupFirstShare()
    func nameValue() -> String?
    func setNameValue(_ value: String?)
    func emailValue() -> String?
    func setEmailValue(_ value: String?)
    func companyValue() -> String?
    func setCompanyValue(_ value: String?)
    func historyCache() -> [HistoryCacheModel]?
    func removeFromHistoryCache(_ model: HistoryCacheModel)
    func saveInHistoryCache(_ value: String)
    func saveSignatureModel(_ model: SignatureModel)
    func deleteSignatureModel(_ type: DrawTypeModel) -> String?
    func loadSignatureModelFor(_ type: DrawTypeModel) -> SignatureModel?
    func saveDocumentModel(_ model: PDFDocumentModel, completion: @escaping (String?) -> Void)
    func deleteDocumentModel(_ documentId: String, completion: @escaping (String?) -> Void)
    func loadDocuments(completion: @escaping ([PDFDocumentModel]?) -> Void)
    func loadDocument(withId documentId: String, completion: @escaping (PDFDocumentModel?) -> Void)
    
    func paintbrushSettings()
    func defaultPaintbrushSettings()
    func savePaintbrushSizeSettings()
    func savePaintbrushColorSettings()
    func savePaintbrushStyleSettings()
}

class BasePresenter: BaseViewOutput {
    
    func isPremium() -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.isPremiumMode
    }
    
    func setPremiumMode(_ status: Bool) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.isPremiumMode = status
    }
    
    func isFirstSign() -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.firstSign
    }
    
    func setupFirstSign() {
        guard !Constants.shared.isTestMode else { return }
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        guard appDataService.firstSign else { return }
        appDataService.firstSign = false
    }
    
    func isFirstShare() -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.firstShare
    }
    
    func setupFirstShare() {
        guard !Constants.shared.isTestMode else { return }
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        guard appDataService.firstShare else { return }
        appDataService.firstShare = false
    }
    
    func nameValue() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.nameValue
    }
    
    func setNameValue(_ value: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.nameValue = value
    }
    
    func emailValue() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.emailValue
    }
    
    func setEmailValue(_ value: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.emailValue = value
    }
    
    func companyValue() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.companyValue
    }
    
    func setCompanyValue(_ value: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.companyValue = value
    }
    
    func historyCache() -> [HistoryCacheModel]? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return HistoryCacheModel.convertDataToModel(appDataService.historyCache)
    }
    
    func removeFromHistoryCache(_ model: HistoryCacheModel) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        guard let data = appDataService.historyCache else { return }
        guard var models = HistoryCacheModel.convertDataToModel(data) else { return }
        
        models.removeAll(where: { $0 == model })
        let data2 = HistoryCacheModel.convertModelToData(models)
        appDataService.historyCache = data2
    }
    
    func saveInHistoryCache(_ value: String) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        let model = HistoryCacheModel(text: value)
        
        guard let data = appDataService.historyCache else {
            appDataService.historyCache = HistoryCacheModel.convertModelToData([model])
            return
        }
        
        guard var models = HistoryCacheModel.convertDataToModel(data) else { return }
        
        guard !models.contains(where: { $0.text == value }) else {
            models.removeAll(where: { $0.text == value })
            models.insert(model, at: 0)
            let data = HistoryCacheModel.convertModelToData(models)
            appDataService.historyCache = data
            return
        }
        
        guard models.count == 10 else {
            models.insert(model, at: 0)
            let data = HistoryCacheModel.convertModelToData(models)
            appDataService.historyCache = data
            return
        }
        
        models.removeAll(where: { $0.text == value })
        models.insert(model, at: 0)
        models = Array(models.prefix(10))
        
        let data2 = HistoryCacheModel.convertModelToData(models)
        appDataService.historyCache = data2
    }
    
    func saveSignatureModel(_ model: SignatureModel) {
        
        let managedContext = AppDelegate.shared.coreDataStack.managedContext
        
        let signature = Signatures(context: managedContext)
        signature.setValue(model.createDate, forKey: #keyPath(Signatures.createDate))
        signature.setValue(model.type.rawValue, forKey: #keyPath(Signatures.type))
        signature.setValue(model.convertImageToData(image: model.image), forKey: #keyPath(Signatures.imageData))
        signature.setValue(model.convertPointsToData(points: model.points), forKey: #keyPath(Signatures.pointsData))
        signature.setValue(model.penColor.rawValue, forKey: #keyPath(Signatures.penColor))
        signature.setValue(model.brush.rawValue, forKey: #keyPath(Signatures.brush))
        
        AppDelegate.shared.coreDataStack.saveContext()
    }
    
    func deleteSignatureModel(_ type: DrawTypeModel) -> String? {
        
        let signaturesFetch: NSFetchRequest<Signatures> = Signatures.fetchRequest()
        
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let result = try managedContext.fetch(signaturesFetch)
            
            guard let signature = result.filter({ type == DrawTypeModel.drawTypeFor($0.type)}).first else {
                return "add.signature.screen.delete.error.message.text".localized()
            }
            
            AppDelegate.shared.coreDataStack.managedContext.delete(signature)
            AppDelegate.shared.coreDataStack.saveContext()
            
            return nil
        } catch let error {
            return error.localizedDescription
        }
    }
    
    func loadSignatureModelFor(_ type: DrawTypeModel) -> SignatureModel? {
        
        let signaturesFetch: NSFetchRequest<Signatures> = Signatures.fetchRequest()
        
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let result = try managedContext.fetch(signaturesFetch)
            
            guard let signature = result.filter({ type == DrawTypeModel.drawTypeFor($0.type)}).first else { return nil }
            guard let image = SignatureModel.convertDataToImage(data: signature.imageData) else { return nil }
            guard let points = SignatureModel.convertDataToPoints(data: signature.pointsData) else { return nil }
            guard let penColor = SignatureColorModel.signatureColorFor(signature.penColor) else { return nil }
            guard let brush = SignatureBrushModel.signatureBrushFor(signature.brush) else { return nil }
            
            return SignatureModel(type: type, image: image, points: points,
                                  penColor: penColor, brush: brush, date: signature.createDate)
        } catch {
            return nil
        }
    }
    
    func saveDocumentModel(_ model: PDFDocumentModel, completion: @escaping (String?) -> Void) {
        
        DispatchQueue.main.async {
            guard let data = model.convertModelToData() else {
                completion("common.error.bad.data".localized())
                return
            }
            
            let documentsFetch: NSFetchRequest<Documents> = Documents.fetchRequest()
            
            do {
                let managedContext = AppDelegate.shared.coreDataStack.managedContext
                let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: documentsFetch) { (results) -> Void in
                    if let finalResult = results.finalResult {
                        if let document = finalResult.filter({ $0.documentId == model.documentId }).first {
                            self.deleteDocumentModel(document.documentId) { error in
                                if let error = error {
                                    completion(error)
                                    return
                                }
                                
                                self.saveDocumentModel(model) { error in
                                    completion(error)
                                }
                            }
                        } else {
                            let document = Documents(context: managedContext)
                            document.setValue(data, forKey: #keyPath(Documents.data))
                            document.setValue(model.documentId, forKey: #keyPath(Documents.documentId))
                            AppDelegate.shared.coreDataStack.saveContext()
                        }
                        
                        completion(nil)
                    }
                }
                    
                try managedContext.execute(asynchronousFetchRequest)
            } catch let error {
                completion(error.localizedDescription)
            }
        }
    }
    
    func deleteDocumentModel(_ documentId: String, completion: @escaping (String?) -> Void) {
        
        DispatchQueue.main.async {
            let documentsFetch: NSFetchRequest<Documents> = Documents.fetchRequest()
        
            do {
                let managedContext = AppDelegate.shared.coreDataStack.managedContext
                let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: documentsFetch) { (results) -> Void in
                    if let finalResult = results.finalResult {
                
                        guard let document = finalResult.filter({ $0.documentId == documentId }).first else {
                            completion("common.error.no.document.id".localized())
                            return
                        }
                        
                        AppDelegate.shared.coreDataStack.managedContext.delete(document)
                        AppDelegate.shared.coreDataStack.saveContext()
                        
                        completion(nil)
                    }
                }
                    
                try managedContext.execute(asynchronousFetchRequest)
            } catch let error {
                completion(error.localizedDescription)
            }
        }
    }
    
    func loadDocuments(completion: @escaping ([PDFDocumentModel]?) -> Void) {
        
        DispatchQueue.main.async {
            var documents: [PDFDocumentModel] = []
            let documentsFetch: NSFetchRequest<Documents> = Documents.fetchRequest()
            
            do {
                let managedContext = AppDelegate.shared.coreDataStack.managedContext
                let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: documentsFetch) { (results) -> Void in
                    if let finalResult = results.finalResult {
                        for result in finalResult {
                            guard let document = PDFDocumentModel.convertDataToModel(data: result.data) else { continue }
                            documents.append(document)
                        }
                        
                        documents.sort(by: { $0.updateDate > $1.updateDate })
                        completion(documents)
                        return
                    }
                    
                    completion(nil)
                }
                
                try managedContext.execute(asynchronousFetchRequest)
            } catch {
                completion(nil)
            }
        }
    }
    
    func loadDocument(withId documentId: String, completion: @escaping (PDFDocumentModel?) -> Void) {
        
        DispatchQueue.main.async {
            let documentsFetch: NSFetchRequest<Documents> = Documents.fetchRequest()
        
            do {
                let managedContext = AppDelegate.shared.coreDataStack.managedContext
                let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: documentsFetch) { (results) -> Void in
                    if let finalResult = results.finalResult {
                        guard let model = finalResult.filter({ $0.documentId == documentId }).first else {
                            completion(nil)
                            return
                        }
                        
                        guard let document = PDFDocumentModel.convertDataToModel(data: model.data) else {
                            completion(nil)
                            return
                        }
                        
                        completion(document)
                    }
                    
                    completion(nil)
                }
                
                try managedContext.execute(asynchronousFetchRequest)
            } catch {
                completion(nil)
            }
        }
    }
    
    func paintbrushSettings() {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        
        //let color = SignatureColorModel.signatureColorFor(appDataService.paintbrushColor) ?? .black
        let style = PaintbrushSettings.convertDataToStyle(appDataService.paintbrushStyle)
        let size = appDataService.paintbrushSize
        
        PaintbrushSettings.shared.setupInstance(style: style, color: .black, size: size)
    }
    
    func defaultPaintbrushSettings() {
        PaintbrushSettings.shared.setupInstance(style: [.bold], color: .black, size: 14)
        
        savePaintbrushStyleSettings()
        savePaintbrushColorSettings()
        savePaintbrushSizeSettings()
    }
    
    func savePaintbrushStyleSettings() {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        let data = PaintbrushSettings.shared.convertStyleToData()
        appDataService.paintbrushStyle = data
    }
    
    func savePaintbrushColorSettings() {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.paintbrushColor = PaintbrushSettings.shared.color.rawValue
    }
    
    func savePaintbrushSizeSettings() {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.paintbrushSize = PaintbrushSettings.shared.size
    }
}

