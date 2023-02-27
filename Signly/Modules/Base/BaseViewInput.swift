//
//  BaseViewInput.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import StoreKit
import ApphudSDK
import SafariServices

protocol BaseViewInput: AnyObject {
    
    func showLoading()
    func showLoading(withTitle title: String)
    func hideLoading()
    func shareDocument(_ document: PDFDocumentModel?)
    func openURL(stringURL: String)
    func openContactDeveloperModule()
    func openTermsOfUse()
    func openPrivacyPolicy()
    func dublicateDocumentTitle(for document: PDFDocumentModel, of documents: [PDFDocumentModel]) -> String
    func restorePurchases()
}

extension BaseViewController: BaseViewInput {
    
    func showLoading() {
        LoadingViewController.title = ""
        LoadingViewController().showLoading(view: self.view)
    }
    
    func showLoading(withTitle title: String) {
        LoadingViewController.title = title
        LoadingViewController().showLoading(view: self.view)
    }
    
    func hideLoading() {
        LoadingViewController().hideLoading()
    }
    
    func shareDocument(_ document: PDFDocumentModel?) {
        guard let document = document else { return }
        
        let activityItems: [Any] = [document.finalData, TextProvider(document)]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func openURL(stringURL: String) {
        if let url = URL(string: stringURL) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let safariController = SFSafariViewController(url: url, configuration: config)
            safariController.preferredControlTintColor = .appBackgroundColor
            safariController.preferredBarTintColor = .appAccentButtonColor
            
            present(safariController, animated: true)
        }
    }
    
    func openContactDeveloperModule() {
        openURL(stringURL: Constants.shared.contactDeveloperURL)
    }
    
    func openTermsOfUse() {
        openURL(stringURL: Constants.shared.termsOfUseURL)
    }
    
    func openPrivacyPolicy() {
        openURL(stringURL: Constants.shared.privacyPolicyURL)
    }
    
    func dublicateDocumentTitle(for document: PDFDocumentModel, of documents: [PDFDocumentModel]) -> String {
        let added = " (" + "main.screen.dublicated.document.added.title.text".localized() + " "
        guard let clearTitle = document.filename.components(separatedBy: added).first else { return document.filename }
        
        for index in 1 ..< 100 {
            let title = clearTitle + String(format: "\(added)%02d)",index)
            if documents.filter({ $0.filename == title }).first == nil { return title }
        }
        
        return document.filename
    }
    
    func signedDocumentTitle(for document: PDFDocumentModel, of documents: [PDFDocumentModel]) -> String {
        let added = " (" + "main.screen.signed.document.added.title.text".localized() + " "
        guard let clearTitle = document.filename.components(separatedBy: added).first else { return document.filename }
        
        for index in 1 ..< 100 {
            let title = clearTitle + String(format: "\(added)%02d)",index)
            if documents.filter({ $0.filename == title }).first == nil { return title }
        }
        
        return document.filename
    }
    
    
    
    func restorePurchases() {
        showLoading()
        Apphud.restorePurchases { subscriptions, purchases, error in
            var appDataService: AppDataServiceProtocol = serviceLocator.getService()
            appDataService.isPremiumMode = Apphud.hasActiveSubscription()
            
            self.hideLoading()
            if let error = error {
                self.showAttentionMessage(error.localizedDescription)
            } else if appDataService.isPremiumMode {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                appDelegate.setupRootViewController()
            } else {
                self.showAttentionMessage("paywall.screen.restore.purchases.no.active.subscription.title".localized())
            }
        }
    }
    
    func openPaywall(isOnboard: Bool = false) {
        guard let navigationController = self.navigationController else { return }
        
        guard !Constants.shared.isTestMode else {
            Constants.shared.getStoreProducts()
            let controller = PaywallModuleConfigurator.instantiateModule()
            controller.isOnboard = isOnboard
            
            if isOnboard {
                navigationController.pushViewController(controller, animated: false)
            } else {
                navigationController.view.layer.add(self.openTransition, forKey: nil)
                navigationController.pushViewController(controller, animated: true)
            }
            
            return
        }
        
        showLoading()
        Apphud.paywallsDidLoadCallback { paywalls in
            if let paywall = paywalls.filter({ $0.identifier == Constants.shared.paywallIdentifier }).first {
                Constants.shared.apphudProducts = paywall.products
                Constants.shared.getStoreProducts()
            }
        
            self.hideLoading()
            
            let controller = PaywallModuleConfigurator.instantiateModule()
            controller.isOnboard = isOnboard
            
            if isOnboard {
                navigationController.pushViewController(controller, animated: false)
            } else {
                navigationController.view.layer.add(self.openTransition, forKey: nil)
                navigationController.pushViewController(controller, animated: true)
            }
        }
    }
    
    func showMessage(_ message: String, withTitle title: String?, completion: @escaping EmptyBlock) {
        
        //let actionTitle = "common.close.button.alert".localized()
        let actionTitle = "common.ok.button.alert".localized()
        
        let alert = CustomAlertController()
        alert.prepareMessageAlert(title: title,
                                  message: message,
                                  actionTitle: actionTitle,
                                  actionType: .ok,
                                  completion: completion)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showMessage(_ message: String, withTitle title: String?) {
        showMessage(message, withTitle: title, completion: {})
    }
    
    func showAttentionMessage(_ message: String, completion: @escaping EmptyBlock) {
        showMessage(message, withTitle: nil, completion: completion)
    }
    
    func showAttentionMessage(_ message: String) {
        showAttentionMessage(message, completion: {})
    }
    
    func showCustomYesNoAlert(_ title: String?, message: String, title1: String, title2: String, comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock) {
        
        let alert = CustomAlertController()
        alert.prepareDoubleActionAlert(title: title,
                                       message: message,
                                       okTitle: title1,
                                       cancelTitle: title2,
                                       okColor: .appSystemColor,
                                       cancelColor: .appSystemColor,
                                       okCompletion: comp1,
                                       cancelCompletion: comp2)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showCustomYesNoAlert(_ title: String?, message: String, title1: String, title2: String, color1: UIColor, color2: UIColor,
                              comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock) {
        
        let alert = CustomAlertController()
        alert.prepareDoubleActionAlert(title: title,
                                       message: message,
                                       okTitle: title1,
                                       cancelTitle: title2,
                                       okColor: color1,
                                       cancelColor: color2,
                                       okCompletion: comp1,
                                       cancelCompletion: comp2)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showTwoActionsAlert(_ title: String?, message: String, title1: String, title2: String, comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock) {
        
        let alert = CustomAlertController()
        alert.prepareTwoActionsAlert(title: title,
                                     message: message,
                                     title1: title1,
                                     title2: title2,
                                     color1: .appSystemColor,
                                     color2: .appSystemColor,
                                     completion1: comp1,
                                     completion2: comp2)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showTwoActionsAlert(_ title: String?, message: String, title1: String, title2: String, color1: UIColor, color2: UIColor,
                             comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock) {
        
        let alert = CustomAlertController()
        alert.prepareTwoActionsAlert(title: title,
                                     message: message,
                                     title1: title1,
                                     title2: title2,
                                     color1: color1,
                                     color2: color2,
                                     completion1: comp1,
                                     completion2: comp2)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showThreeActionsAlert(_ title: String?, message: String, title1: String, title2: String, title3: String,
                               actionType3: CustomTypeButtonAlertEnum, comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock,
                               comp3: @escaping EmptyBlock) {
        
        let alert = CustomAlertController()
        alert.prepareThreeActionAlert(title: title, message: message, title1: title1, title2: title2, title3: title3,
                                      actionType3: actionType3, completion1: comp1, completion2: comp2, completion3: comp3)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func showTextFieldAlert(_ title: String?, message: String, doneTitle: String, cancelTitle: String,
                            startValue: String, placeholder: String?, keyboardType: UIKeyboardType = .default,
                            completion: @escaping EditValueBlock) {
        
        let alert = CustomAlertController()
        alert.prepareTextFieldAlert(title: title, message: message, doneTitle: doneTitle, cancelTitle: cancelTitle,
                                    startValue: startValue, placeholder: placeholder, keyboardType: keyboardType, completion: completion)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
}
