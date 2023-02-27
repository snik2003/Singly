//
//  WhiteButton.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit

final class WhiteButton: UIButton {
    
    override var isEnabled: Bool {
        didSet { handleState() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEnabled = true
        setupStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        self.backgroundColor = isEnabled ? .white : .appDarkTextColor30
        self.setTitleColor(isEnabled ? .appSystemColor : .appDarkTextColor60, for: .highlighted)
        self.setTitleColor(isEnabled ? .appSystemColor : .appDarkTextColor60, for: .normal)
        layer.borderWidth = isEnabled ? 0.0 : 0.0
    }
    
    private func setupStyle() {
        setBackgroundColor()
        setCornerRadius(radius: 16)
        setShadow()
        
        titleLabel?.font = .appHeadline3
        titleLabel?.textColor = isEnabled ? .appSystemColor : .appDarkTextColor60
        
        setTitleColor(isEnabled ? .appSystemColor : .appDarkTextColor60, for: .highlighted)
        setTitleColor(isEnabled ? .appSystemColor : .appDarkTextColor60, for: .normal)
    }
    
    private func handleState() {
        let animations: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.setBackgroundColor()
        }
        
        UIView.animate(withDuration: 0.3, animations: animations)
    }
    
    private func setShadow() {
        clipsToBounds = false
        layer.shadowColor = UIColor.appDarkTextColor60.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 16.0
        layer.masksToBounds = false
    }
}



