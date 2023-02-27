//
//  OnboardPresenter.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import OneSignal
import ApphudSDK

protocol OnboardViewOutput {
    func viewLoaded()
    func pushRequest()
    func setupFirstLaunch()
}

final class OnboardPresenter {
    
    weak var view: OnboardViewInput?
    private var appDataService: AppDataServiceProtocol
    
    var onboard: OnboardModel
    
    init(onboard: OnboardModel, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.onboard = onboard
    }
}

extension OnboardPresenter: OnboardViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(onboard: onboard)
    }
    
    func setupFirstLaunch() {
        appDataService.firstLaunch = false
    }
    
    func pushRequest() {
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
        
        OneSignal.setExternalUserId(Apphud.userID())
    }
}
