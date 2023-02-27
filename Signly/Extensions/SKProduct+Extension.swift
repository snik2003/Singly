//
//  SKProduct+Extension.swift
//  CDL
//
//  Created by Сергей Никитин on 05.08.2022.
//

import StoreKit
import ApphudSDK

extension SKProduct.PeriodUnit {
    func toCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            debugPrint("Unknown period unit")
        }
        return .day
    }
}

extension SKProductSubscriptionPeriod {
    func localizedPeriod() -> String? {
        guard numberOfUnits > 0 else { return nil }
        guard unit.toCalendarUnit() == .day && numberOfUnits == 7 else {
            return PeriodFormatter.format(unit: unit.toCalendarUnit(), numberOfUnits: numberOfUnits)
        }
        
        return PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 1)
    }
}

extension SKProduct {
    
    static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = " "
        numberFormatter.currencyGroupingSeparator = " "
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    func localizedPriceText(discount: Bool = false) -> String {
        var priceText: String = ""
        
        if let currencySymbol = self.priceLocale.currencySymbol {
            priceText = currencySymbol + ""
        }
        
        if discount, let introPrice = introductoryPrice, let price = SKProduct.numberFormatter.string(from: introPrice.price) {
            priceText += price
        } else if let price = SKProduct.numberFormatter.string(from: self.price) {
            priceText += price
        }
        
        if let subscriptionPeriod = self.subscriptionPeriod, let localizedPeriod = subscriptionPeriod.localizedPeriod() {
            priceText += " / " + localizedPeriod
        }
        
        return priceText
    }
    
    func localizedTitle() -> String {
        
        guard localizedTitle.isEmpty else { return localizedTitle }
        guard let title = productIdentifier.components(separatedBy: ".").last else { return "" }
        return title.lowercased().capitalizingFirstLetter()
    }
    
    func localizedFullPriceText() -> String {
        guard let currencySymbol = self.priceLocale.currencySymbol else { return "" }
        guard let price = SKProduct.numberFormatter.string(from: self.price) else { return "" }
        
        return currencySymbol + "" + price
    }
    
    func localizedIntroductoryPriceText() -> String {
        guard let introductoryPrice = self.introductoryPrice else { return "" }
        guard let currencySymbol = self.priceLocale.currencySymbol else { return "" }
        guard let price = SKProduct.numberFormatter.string(from: introductoryPrice.price) else { return "" }
        
        return currencySymbol + " " + price
    }
    
    func printProduct() {
        print("productID = \(self.productIdentifier)")
        print("description = \(self.localizedDescription)")
        print("title = \(self.localizedTitle)")
        print("price = \(self.price)")
        print("locale = \(self.priceLocale.identifier)")
        
        if let subscriptionPeriod = self.subscriptionPeriod {
            print("subscription period unit = \(subscriptionPeriod.unit)")
            print("subscription period number = \(subscriptionPeriod.numberOfUnits)")
        }
        
        if let introductoryPrice = self.introductoryPrice {
            print("introductory price = \(introductoryPrice.price)")
            print("introductory locale = \(introductoryPrice.priceLocale.identifier)")
            print("introductory payment mode = \(introductoryPrice.paymentMode)")
            print("introductory price unit = \(introductoryPrice.subscriptionPeriod.unit)")
            print("introductory price number = \(introductoryPrice.subscriptionPeriod.numberOfUnits)")
        }
    }
}

@available(iOS 11.2, *)
extension SKProductDiscount {
    func localizedTrialPeriod() -> String? {
        
        switch paymentMode {
        case PaymentMode.freeTrial:
            guard let period = subscriptionPeriod.localizedPeriod() else { return nil }
            return period + " " + "paywall.screen.product.trial.period.added.text".localized()
        default:
            return nil
        }
    }
}


