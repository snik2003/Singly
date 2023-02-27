//
//  AppDataService.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation
import KeychainSwift

fileprivate enum AppDataKey: String {
    case firstLaunchKey
    case isPremiumModeKey
    case nameValueKey
    case emailValueKey
    case companyValueKey
    case firstSignKey
    case firstShareKey
    case historyCacheKey
    case paintbrushStyleKey
    case paintbrushColorKey
    case paintbrushSizeKey
}

protocol AppDataServiceProtocol {
    var firstLaunch: Bool { get set }
    var isPremiumMode: Bool { get set }
    var nameValue: String? { get set }
    var emailValue: String? { get set }
    var companyValue: String? { get set }
    var firstSign: Bool { get set }
    var firstShare: Bool { get set }
    var historyCache: Data? { get set }
    var paintbrushStyle: Data? { get set }
    var paintbrushColor: String { get set }
    var paintbrushSize: CGFloat { get set }
}

final class AppDataService {
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainSwift
    
    init() {
        userDefaults = UserDefaults()
        keychain = KeychainSwift()
    }
}

//MARK:- UserDataServiceProtocol
extension AppDataService: AppDataServiceProtocol {
    
    var firstLaunch: Bool {
        get { return boolValue(for: .firstLaunchKey) ?? true }
        set { setValue(newValue, for: .firstLaunchKey) }
    }
    
    var isPremiumMode: Bool {
        get { return boolValue(for: .isPremiumModeKey) ?? false }
        set { setValue(newValue, for: .isPremiumModeKey) }
    }
    
    var nameValue: String? {
        get { return value(for: .nameValueKey) }
        set { setValue(newValue, for: .nameValueKey) }
    }
              
    var emailValue: String? {
        get { return value(for: .emailValueKey) }
        set { setValue(newValue, for: .emailValueKey) }
    }
    
    var companyValue: String? {
        get { return value(for: .companyValueKey) }
        set { setValue(newValue, for: .companyValueKey) }
    }
    
    var firstSign: Bool {
        get { return boolValue(for: .firstSignKey) ?? true }
        set { setValue(newValue, for: .firstSignKey) }
    }
    
    var firstShare: Bool {
        get { return boolValue(for: .firstShareKey) ?? true }
        set { setValue(newValue, for: .firstShareKey) }
    }
    
    var historyCache: Data? {
        get { return anyValue(for: .historyCacheKey) as? Data }
        set { setValue(newValue, for: .historyCacheKey) }
    }
    
    var paintbrushStyle: Data? {
        get { return anyValue(for: .paintbrushStyleKey) as? Data }
        set { setValue(newValue, for: .paintbrushStyleKey) }
    }
    
    var paintbrushColor: String {
        get { return value(for: .paintbrushColorKey) ?? SignatureColorModel.allCases.first!.rawValue }
        set { setValue(newValue, for: .paintbrushColorKey) }
    }
    
    var paintbrushSize: CGFloat {
        get { return anyValue(for: .paintbrushSizeKey) as? CGFloat ?? 13.0  }
        set { setValue(newValue, for: .paintbrushSizeKey) }
    }
}

//MARK:- Setup values
extension AppDataService {
    
    fileprivate func value(for key: AppDataKey) -> String? {
        return userDefaults.object(forKey: key.rawValue) as? String
    }
    
    fileprivate func masStringValue(for key: AppDataKey) -> [String]? {
        return userDefaults.object(forKey: key.rawValue) as? [String]
    }
    
    fileprivate func boolValue(for key: AppDataKey) -> Bool? {
        return userDefaults.object(forKey: key.rawValue) as? Bool
    }
    
    fileprivate func intValue(for key: AppDataKey) -> Int? {
        return userDefaults.object(forKey: key.rawValue) as? Int
    }
    
    fileprivate func anyValue(for key: AppDataKey) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    fileprivate func setValue(_ value: Any?, for key: AppDataKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    fileprivate func setSecureValue(_ value: String?, for key: AppDataKey) {
        guard let value = value else { self.keychain.delete(key.rawValue); return }
        keychain.set(value, forKey: key.rawValue)
    }
    
    fileprivate func secureValue(for key: AppDataKey) -> String? {
        return keychain.get(key.rawValue)
    }
}

