//
//  UpgradeView.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

class UpgradeView: UIView {
    
    static let color1 = UIColor(red: 0.967, green: 0.725, blue: 0, alpha: 1)
    static let color2 = UIColor(red: 0.879, green: 0.58, blue: 0, alpha: 1)
    static let color3 = UIColor(red: 0.973, green: 0.973, blue: 0.98, alpha: 1)
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    var delegate: BaseViewController?
    
    var animateHideWhileAction = false
    
    var headerMessage = "upgrade.view.header.title".localized()
    var upgradeMessage: String?
    var actionMessage: String?
    
    var backView: UIView!
    
    func configure() {
        removeFromSuperview()
        backgroundColor = .clear
        let width = UIScreen.main.bounds.width - 32
        
        backView = UIView()
        backView.clipsToBounds = true
        backView.frame = CGRect(x: 16, y: 24, width: width, height: 500)
        
        var height: CGFloat = 16
        
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 96, y: height, width: width - 96 - 16, height: 36)
        headerLabel.text = headerMessage
        headerLabel.textColor = .white
        headerLabel.font = .appHeadline1
        backView.addSubview(headerLabel)
        
        height += 36
        
        if let upgradeMessage = upgradeMessage, !upgradeMessage.isEmpty {
            let messageLabel = UILabel()
            messageLabel.frame = CGRect(x: 96, y: height, width: width - 96 - 16, height: 16)
            messageLabel.text = upgradeMessage
            messageLabel.adjustsFontSizeToFitWidth = true
            messageLabel.minimumScaleFactor = 0.5
            messageLabel.textColor = .white
            messageLabel.font = .appHintText
            backView.addSubview(messageLabel)
            
            height += 16
        }
        
        
        if let actionMessage = actionMessage, !actionMessage.isEmpty {
            let actionLabel = UILabel()
            actionLabel.frame = CGRect(x: 96, y: height, width: width - 96 - 16, height: 32)
            actionLabel.text = actionMessage
            actionLabel.textColor = .white
            actionLabel.font = .appSecondaryBodyText
            backView.addSubview(actionLabel)
            
            height += 32
        }
        
        height += 16
        
        let iconView = UIView()
        iconView.frame = CGRect(x: 28, y: (height - 40) / 2, width: 40, height: 40)
        iconView.backgroundColor = UpgradeView.color3
        iconView.layer.cornerRadius = 20
        iconView.clipsToBounds = true
        iconView.alpha = 0.4
        backView.addSubview(iconView)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "crown")
        imageView.frame = CGRect(x: 28, y: (height - 40) / 2, width: 40, height: 40)
        
        backView.addSubview(imageView)
        
        
        backView.frame = CGRect(x: 16, y: 24, width: width, height: height)
        backView.gradientBackgroundColor2(color1: UpgradeView.color1, color2: UpgradeView.color2)
        backView.layer.cornerRadius = 12
        self.addSubview(backView)
        
        
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        button.frame = CGRect(x: 16, y: 24, width: width, height: height)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.addSubview(button)
        
        self.width = width + 32
        self.height = height + 48
        self.frame = CGRect(x: 0, y: -self.height, width: self.width, height: self.height)
        self.alpha = 0.0
        
        guard let delegate = self.delegate else { return }
        delegate.view.addSubview(self)
    }
    
    func showUpgradeView(at topY: CGFloat, animated: Bool = true, completion: EmptyBlock? = nil) {
        guard animated else {
            self.frame = CGRect(x: 0, y: topY, width: self.width, height: self.height)
            self.alpha = 1.0
            completion?()
            return
        }
        
        self.frame = CGRect(x: 0, y: -self.height, width: self.width, height: self.height)
        self.alpha = 1.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: topY, width: self.width, height: self.height)
        }, completion: { _ in
            completion?()
        })
    }
    
    func hideUpgradeView(animated: Bool = false, completion: EmptyBlock? = nil) {
        guard animated else {
            self.alpha = 0.0
            self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.width, height: self.height)
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.7, animations: {
            self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.width, height: self.height)
        }, completion: { _ in
            self.alpha = 0.0
            completion?()
        })
    }
    
    @objc
    private func buttonAction() {
        guard let backView = self.backView else { return }
        guard let delegate = self.delegate else { return }
        
        backView.viewTouched {
            self.hideUpgradeView(animated: self.animateHideWhileAction) {
                delegate.openPaywall()
            }
        }
    }
    
}
