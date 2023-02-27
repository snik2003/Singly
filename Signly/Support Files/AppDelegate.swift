//
//  AppDelegate.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import StoreKit
import IQKeyboardManager

import OneSignal
import ApphudSDK

import AdServices
import iAd

import FirebaseCore
import FirebaseAnalytics
import YandexMobileMetrica

var serviceLocator: ServiceLocator!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var orientationLock: UIInterfaceOrientationMask = .portrait
    
    lazy var coreDataStack: CoreDataStack = .init(modelName: "SignlyModel")

    static let shared: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unexpected app delegate type, did it change? \(String(describing: UIApplication.shared.delegate))")
        }
        
        return delegate
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared().isEnabled = false
        
        setupAppHudServices()
        setupYandexServices()
        setupFirebaseServices()
        setupOneSignalServices(launchOptions: launchOptions)
        
        setupLocalServices()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Constants.shared.importedDocumentURL = url
        
        guard let window = window else { return true }
        guard let navigationController = window.rootViewController as? UINavigationController else { return true }
        
        guard let controller = navigationController.topViewController as? MainViewController else {
            navigationController.popToRootViewController(animated: true)
            return true
        }
        
        controller.handleImportedDoucment()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return orientationLock
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.shared.coreDataStack.saveContext()
    }
}

extension AppDelegate {
    
    func setupLocalServices() {
        let registry = LazyServiceLocator()
        serviceLocator = registry

        var appDataService: AppDataServiceProtocol = AppDataService()
        appDataService.isPremiumMode = Apphud.hasPremiumAccess()
    
        if Constants.shared.isTestMode {
            //appDataService.firstLaunch = true
            appDataService.firstSign = true
            appDataService.firstShare = true
        }
        
        registry.addService { appDataService }
        
        setupLaunchViewController()
        
        if appDataService.firstLaunch {
            setupOnboardViewController()
        } else {
            appDataService.isPremiumMode ? setupRootViewController() : setupPaywallViewController()
        }
    }
    
    func setupLaunchViewController() {
        guard let window = window else { return }
                
        let viewController = LaunchViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func setupOnboardViewController() {
        guard let window = window else { return }
                
        let controller = OnboardModuleConfigurator.instantiateModule()
        let navigationController = UINavigationController()
        navigationController.navigationBar.tintColor = .appBackgroundColor
        navigationController.toolbar.tintColor = .appAccentButtonColor
        
        navigationController.viewControllers = [controller]
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func setupPaywallViewController() {
        guard let window = window else { return }
        
        Apphud.paywallsDidLoadCallback { paywalls in
            if let paywall = paywalls.filter({ $0.identifier == Constants.shared.paywallIdentifier }).first {
                Constants.shared.apphudProducts = paywall.products
                Constants.shared.getStoreProducts()
            }
        
            let controller = PaywallModuleConfigurator.instantiateModule()
            let navigationController = UINavigationController()
            navigationController.viewControllers = [controller]
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    func setupRootViewController() {
        guard let window = window else { return }
                
        let controller = MainModuleConfigurator.instantiateModule()
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension AppDelegate {
    
    fileprivate func setupAppHudServices() {
        
        Apphud.start(apiKey: Constants.shared.appHudApiKey)
        Apphud.setDelegate(self)
        
        trackAppleSearchAds()
        
        guard Constants.shared.isTestMode else { return }
        print("APPHUD SERVICES 🛍")
    }
    
    fileprivate func setupYandexServices() {
        
        guard !Constants.shared.isTestMode else {
            print("YANDEX METRICA 🔔")
            return
        }
        
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: Constants.shared.appMetrikaApiKey) {
            YMMYandexMetrica.activate(with: configuration)
            YMMYandexMetrica.setUserProfileID(Apphud.userID())
        }
    }
    
    fileprivate func setupFirebaseServices() {
        
        guard !Constants.shared.isTestMode else {
            print("GOOGLE FIREBASE 🧲")
            return
        }
        
        FirebaseApp.configure()
        
        Analytics.setUserID(Apphud.userID())
        if let instanceID = Analytics.appInstanceID() {
            Apphud.addAttribution(data: nil, from: .firebase, identifer: instanceID,  callback: nil)
        }
    }
    
    fileprivate func setupOneSignalServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        guard !Constants.shared.isTestMode else {
            print("ONE SIGNAL 💬")
            return
        }
        
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(Constants.shared.oneSignalAppID)
        OneSignal.setExternalUserId(Apphud.userID())
    }
    
    
    fileprivate func trackAppleSearchAds() {
        if #available(iOS 14.3, *) {
            DispatchQueue.global(qos: .default).async {
                if let token = try? AAAttribution.attributionToken() {
                    DispatchQueue.main.async {
                        Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: token, callback: nil)
                    }
                }
            }
        } else {
            ADClient.shared().requestAttributionDetails { data, _ in
                data.map { Apphud.addAttribution(data: $0, from: .appleSearchAds, callback: nil) }
            }
        }
    }
}



extension AppDelegate: ApphudDelegate {
    
    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        print("appHud products count = \(products.count)")
    }

    func apphudDidFetchStoreKitProducts(_ products: [SKProduct], _ error: Error?) {
        guard let error = error else { return }
        print("appHud products error = \(error.localizedDescription)")
    }

    func apphudDidObservePurchase(result: ApphudPurchaseResult) -> Bool {
        print("Did observe purchase made without Apphud SDK: \(result)")
        return true
    }
    
    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? {
        let callback : ((ApphudPurchaseResult) -> Void) = { [weak self] result in
            guard let self = self else { return }
            
            var appDataService: AppDataServiceProtocol = serviceLocator.getService()
            appDataService.isPremiumMode = Apphud.hasPremiumAccess()
            self.setupRootViewController()
        }
        
        return callback
    }
}

