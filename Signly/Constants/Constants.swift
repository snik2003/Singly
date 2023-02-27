//
//  Constants.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import StoreKit
import AVFoundation
import ApphudSDK

let emptyClosure: () -> Void = {  }

typealias EmptyBlock = () -> Void
typealias EditValueBlock = (String) -> Void
typealias SuccessfulCompletion = (_ success: Bool) -> ()
typealias ErrorCompletion = (_ error: String?) -> Void

final class Constants {
    static let shared = Constants()
    
    let testBundleID = "com.reapps.signly"
    
    // устанавливать true только для тестирования приложения
    let isTestMode = false
    
    // количество пульсирующих анимаций на главном экране
    let maxPulseAnimationCount = 6
    
    // Api_key для интеграции AppHud
    let appHudApiKey = "app_dWYwYbmdPvC9iKSCeCfx6BcyFdt7zQ"
    
    // Api_key для интеграции Yandex AppMetrics
    let appMetrikaApiKey = "5566a08b-a7aa-4695-8298-b67940c465eb"
    
    // Api_key для интеграции Google Firebase Analitycs
    let firebaseBundle = "com.signature.singly"
    
    // Api_key для интеграции OneSignal PushNotifications
    let oneSignalAppID = "0322dfb2-4d3d-40ff-97b2-7bb0f8493904"
    
    // URL раздела "Contact Developer"
    let contactDeveloperURL = "https://forms.gle/gvkkcYmD1VAswCuc7"
    
    // URL раздела "Terms of Use"
    let termsOfUseURL = "https://docs.google.com/document/d/1l108dzVGcGI64o-atD8vrsgRpOVaRofQ6yd6HEa9EjU/edit?usp=sharing"
    
    // URL раздела "Privacy Policy"
    let privacyPolicyURL = "https://docs.google.com/document/d/1mqoaN5e7OmU83So3ccfKw8pMNOqdf41_Wa1Bjc0oStY/edit?usp=sharing"
    
    // AppHud integration
    let paywallIdentifier = "Main"
    
    // Products for Paywall
    var demoProducts: [SKProduct] = []
    var storeProducts: [SKProduct] = []
    var apphudProducts: [ApphudProduct] = []
    
    var importedDocumentURL: URL? = nil
    
    var needUpdateRequest = true
    
    func getStoreProducts() {
        storeProducts = []
        
        for index in 0 ..< apphudProducts.count {
            guard let product = apphudProducts[index].skProduct else { continue }
            storeProducts.append(product)
        }
        
        guard isTestMode else { return }
        guard storeProducts.isEmpty else { return }
        storeProducts = PSKProduct.getDemoProducts()
    }
}

