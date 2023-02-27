//
//  PSKProduct.swift
//  Singly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import Foundation
import StoreKit

class PSKProduct: SKProduct {
    
    private let _localizedTitle: String
    private let _price: NSDecimalNumber
    private let _priceLocale: Locale
    private let _introductoryPrice: SKProductDiscount?
    private let _subscriptionPeriod: SKProductSubscriptionPeriod?
    
    init(localizesTitle: String,
         price: NSDecimalNumber,
         priceLocale: Locale,
         introductoryPrice: SKProductDiscount?,
         subscriptionPeriod: SKProductSubscriptionPeriod?) {
        
        _localizedTitle = localizesTitle
        _price = price
        _priceLocale = priceLocale
        _introductoryPrice = introductoryPrice
        _subscriptionPeriod = subscriptionPeriod
    }
    
    override var localizedTitle: String {
        self._localizedTitle
    }
    
    override var price: NSDecimalNumber {
        self._price
    }
    
    override var priceLocale: Locale {
        self._priceLocale
    }
    
    override var introductoryPrice: SKProductDiscount? {
        self._introductoryPrice
    }
    
    override var subscriptionPeriod: SKProductSubscriptionPeriod? {
        self._subscriptionPeriod
    }
    
    class func getDemoProducts() -> [SKProduct] {
        
        var array: [SKProduct] = []
        
        let paymentMode1 = SKProductDiscount.PaymentMode.freeTrial
        let subscriptionPeriod1 = PSKProductSubscriptionPeriod(numberOfUnits: 1, unit: .day)
        let introductoryPrice1 = PSKProductDiscount(price: 7.49,
                                                    priceLocale: Locale(identifier: "en-US"),
                                                    paymentMode: paymentMode1,
                                                    subscriptionPeriod: subscriptionPeriod1)
        
        
        let product1 = PSKProduct(localizesTitle: "Name 1",
                                  price: NSDecimalNumber(value: 7.49),
                                  priceLocale: Locale(identifier: "en-US"),
                                  introductoryPrice: introductoryPrice1,
                                  subscriptionPeriod: PSKProductSubscriptionPeriod(numberOfUnits: 7, unit: .day))
        array.append(product1)
        
        
        let paymentMode2 = SKProductDiscount.PaymentMode.freeTrial
        let subscriptionPeriod2 = PSKProductSubscriptionPeriod(numberOfUnits: 3, unit: .day)
        let introductoryPrice2 = PSKProductDiscount(price: 29.49,
                                                    priceLocale: Locale(identifier: "en-US"),
                                                    paymentMode: paymentMode2,
                                                    subscriptionPeriod: subscriptionPeriod2)
        
        let product2 = PSKProduct(localizesTitle: "Name 2",
                                  price: NSDecimalNumber(value: 29.49),
                                  priceLocale: Locale(identifier: "en-US"),
                                  introductoryPrice: introductoryPrice2,
                                  subscriptionPeriod: PSKProductSubscriptionPeriod(numberOfUnits: 1, unit: .month))
        
        array.append(product2)
        
        
        let paymentMode3 = SKProductDiscount.PaymentMode.freeTrial
        let subscriptionPeriod3 = PSKProductSubscriptionPeriod(numberOfUnits: 5, unit: .day)
        let introductoryPrice3 = PSKProductDiscount(price: 59.99,
                                                   priceLocale: Locale(identifier: "en-US"),
                                                   paymentMode: paymentMode3,
                                                   subscriptionPeriod: subscriptionPeriod3)
        
        let product3 = PSKProduct(localizesTitle: "Name 3",
                                  price: NSDecimalNumber(value: 59.99),
                                  priceLocale: Locale(identifier: "en-US"),
                                  introductoryPrice: introductoryPrice3,
                                  subscriptionPeriod: PSKProductSubscriptionPeriod(numberOfUnits: 3, unit: .month))
        array.append(product3)
        
        
        return array
    }
}

class PSKProductSubscriptionPeriod: SKProductSubscriptionPeriod {
    
    private let _numberOfUnits: Int
    private let _unit: SKProduct.PeriodUnit

    init(numberOfUnits: Int = 1, unit: SKProduct.PeriodUnit = .year) {
        _numberOfUnits = numberOfUnits
        _unit = unit
    }

    override var numberOfUnits: Int {
        self._numberOfUnits
    }

    override var unit: SKProduct.PeriodUnit {
        self._unit
    }
}

class PSKProductDiscount: SKProductDiscount {
    
    private let _price: NSDecimalNumber
    private let _priceLocale: Locale
    private let _paymentMode: SKProductDiscount.PaymentMode
    private let _subscriptionPeriod: SKProductSubscriptionPeriod

    init(price: NSDecimalNumber = 0,
         priceLocale: Locale,
         paymentMode: PSKProductDiscount.PaymentMode,
         subscriptionPeriod: SKProductSubscriptionPeriod) {
        
        _price = price
        _priceLocale = priceLocale
        _paymentMode = paymentMode
        _subscriptionPeriod = subscriptionPeriod
    }
    
    override var price: NSDecimalNumber {
        self._price
    }
    
    override var priceLocale: Locale {
        self._priceLocale
    }
    
    override var paymentMode: SKProductDiscount.PaymentMode {
        self._paymentMode
    }
    
    override var subscriptionPeriod: SKProductSubscriptionPeriod {
        self._subscriptionPeriod
    }
}

