//
//  PremiumCell.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

class PremiumCell: BaseTableCell {
    
    weak var delegate: BaseViewController?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        
        backView.viewTouched {
            delegate.openPaywall()
        }
    }
}

extension PremiumCell {
    
    func configure() {
        backView.gradientBackgroundColor2(color1: UpgradeView.color1, color2: UpgradeView.color2)
        backView.layer.cornerRadius = 12
        backView.clipsToBounds = true
        
        iconView.backgroundColor = UpgradeView.color3
        iconView.layer.cornerRadius = 20
        iconView.clipsToBounds = true
        iconView.alpha = 0.4
        
        titleLabel.text = "paywall.banner.title.text".localized()
        titleLabel.textColor = .white
        titleLabel.font = .appHeadline1
        
        subtitleLabel.text = "paywall.banner.subtitle.text".localized()
        subtitleLabel.textColor = .white
        subtitleLabel.font = .appSmallBodyText
    }
}
