//
//  ProductCell.swift
//  CDL
//
//  Created by Сергей Никитин on 09.08.2022.
//

import UIKit
import StoreKit
import ApphudSDK

class ProductCell: BaseCollectionViewCell {

    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = " "
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }
    
    let selectedColor = UIColor.appSystemColor60
    let deselectedColor = UIColor.appSystemColor30
    
    let popularViewColor = UIColor.appGoodStatusColor
    let percentColor = UIColor.appDangerousStatusColor
    let freeLabelColor = UIColor.appBadStatusColor
    let periodLabelColor = UIColor.appDarkTextColor
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var popularIcon: UIImageView!
    @IBOutlet weak var popularLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    @IBOutlet weak var freeView: UIView!
    @IBOutlet weak var freeLabel: UILabel!
    
    @IBOutlet weak var percentView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountLabel: UILabel!
    
    @IBOutlet weak var discountLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLabelTopConstraint: NSLayoutConstraint!
    
    override var isSelected: Bool {
        willSet {
            self.backView.layer.borderWidth = newValue ? 2.0 : 1.0
            self.backView.layer.borderColor = newValue ? UIColor.appSystemColor.cgColor : UIColor.white.cgColor
            self.backView.backgroundColor = newValue ? selectedColor : deselectedColor
        }
    }
}

extension ProductCell {
    
    func reset() {
        self.backView.backgroundColor = deselectedColor
        self.backView.layer.borderColor = UIColor.white.cgColor
        self.backView.layer.cornerRadius = 12
        self.backView.layer.borderWidth = 1.0
        
        self.popularView.backgroundColor = popularViewColor
        self.popularView.layer.cornerRadius = 8
        self.popularView.isHidden = true
        
        self.popularLabel.text = "paywall.screen.default.popular.product.title".localized().uppercased()
        self.popularLabel.textColor = .white
        self.popularLabel.font = .appSmallUppercaseText
        
        self.popularIcon.tintColor = .white
        
        self.titleLabel.textColor = .appDarkTextColor80
        self.titleLabel.font = .appSmallSemiboldBodyText
        self.titleLabel.isHidden = false
        
        self.priceLabel.textColor = .appDarkTextColor
        self.priceLabel.font = .appHeadline1
        self.priceLabelTopConstraint.constant = 0
        self.priceLabel.isHidden = false
        
        self.periodLabel.text = "paywall.screen.product.lifetime.purchase.title".localized()
        self.periodLabel.textColor = periodLabelColor
        self.periodLabel.font = .appSmallUppercaseText
        
        self.freeView.backgroundColor = freeLabelColor
        self.freeView.layer.cornerRadius = 8
        self.freeView.isHidden = true
        
        self.freeLabel.text = "paywall.screen.product.trial.period.title".localized()
        self.freeLabel.textColor = .white
        self.freeLabel.font = .appSmallUppercaseText
        
        self.percentLabel.textColor = .white
        self.percentLabel.font = .appSmallUppercaseText
        
        self.percentView.backgroundColor = percentColor
        self.percentView.layer.cornerRadius = 8
        self.percentView.isHidden = true
        
        self.discountLabel.textColor = .appDarkTextColor60
        self.discountLabelHeightConstraint.constant = 0
        self.discountLabel.font = .appSecondaryBodyText
        
        self.discountView.backgroundColor = .appDarkTextColor60
        self.discountView.isHidden = true
    }
    
    func configure(product: SKProduct, isPopular: Bool = false) {
        self.reset()
        
        if isPopular {
            self.popularView.isHidden = false
        }
        
        self.titleLabel.text = product.localizedTitle().uppercased()
        self.priceLabel.text = product.localizedFullPriceText()
        
        if let subscriptionPeriod = product.subscriptionPeriod, let localizedPeriod = subscriptionPeriod.localizedPeriod() {
            periodLabel.text = "paywall.screen.product.subscription.period.added.text".localized() + " " + localizedPeriod
            titleLabel.text = localizedPeriod.replacingOccurrences(of: "1 ", with: "").uppercased()
        } else {
            titleLabel.text = "paywall.screen.product.lifetime.purchase.period.title".localized().uppercased()
        }
        
        if let introductoryPrice = product.introductoryPrice {
            if let trialText = introductoryPrice.localizedTrialPeriod() {
                self.freeView.isHidden = false
                self.freeLabel.text = trialText.uppercased()
                self.freeLabel.sizeToFit()
            }
            
            if introductoryPrice.price.doubleValue > 0 && product.price.doubleValue > 0 &&
                introductoryPrice.price.doubleValue < product.price.doubleValue {
                
                let pDouble = 100.0 - introductoryPrice.price.doubleValue / product.price.doubleValue * 100.0
                let percent = NSNumber(value: pDouble)
                
                if let text = numberFormatter.string(from: percent) {
                    priceLabel.text = product.localizedIntroductoryPriceText()
                    
                    percentLabel.text = "-" + text + "%"
                    popularView.isHidden = true
                    
                    percentView.isHidden = false
                    
                    priceLabelTopConstraint.constant = 8
                    discountLabelHeightConstraint.constant = 18
                    
                    discountLabel.text = product.localizedFullPriceText()
                    discountLabel.isHidden = false
                    discountView.isHidden = false
                }
            }
            
        }
    }
}


