//
//  SettingsCustomCell.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

class SettingsCustomCell: BaseTableCell {

    weak var delegate: SettingsViewController?
    
    var model: SettingsModel?
    var hasSignature = false
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var signImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addDotterLine()
    }
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        button.viewTouched {
            switch model {
            case .signature:
                delegate.addSignature()
            case .initials:
                delegate.addInititals()
            default:
                break
            }
        }
    }
    
    @IBAction func editButtonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        editButton.viewTouched {
            model == .signature ? delegate.editSignature() : delegate.editInitials()
        }
    }
    
    @IBAction func deleteButtonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        deleteButton.viewTouched {
            model == .signature ? delegate.deleteSignature() : delegate.deleteInitials()
        }
    }
}

extension SettingsCustomCell {
    
    func configure(model: SettingsModel, signature: SignatureModel?) {
        self.model = model
        self.hasSignature = signature != nil
        self.backView.backgroundColor = .clear
        
        label.text = model.title.uppercased()
        label.textColor = .appDarkTextColor60
        label.font = .appUppercaseText
        
        button.setTitle(model.placeholder, for: .normal)
        button.setTitleColor(.appSystemColor, for: .normal)
        button.titleLabel?.font = .appHeadline3
        
        button.alpha = 1.0
        signImage.alpha = 0.0
        editButton.alpha = 0.0
        deleteButton.alpha = 0.0
        
        guard let signature = signature else { return }
        
        button.alpha = 0.0
        
        editButton.alpha = 1.0
        editButton.tintColor = .appSystemColor60
        
        deleteButton.alpha = 1.0
        deleteButton.tintColor = .appDangerousStatusColor
        
        signImage.backgroundColor = .white
        signImage.image = signature.image
        signImage.alpha = 1.0
        
        self.layoutSubviews()
    }
    
    func removeDotterLine() {
        guard let sublayers = signImage.layer.sublayers else { return }
        
        for sublayer in sublayers {
            if sublayer is CAShapeLayer { sublayer.removeFromSuperlayer() }
        }
    }
    
    func addDotterLine() {
        removeDotterLine()
        
        guard hasSignature else { return }
        
        let width = bounds.width - 32
        let rect = CGRect(x: 0, y: 0, width: width, height: width / 2)
        let dotterLayer = CAShapeLayer()
        dotterLayer.strokeColor = UIColor.appSystemColor30.cgColor
        dotterLayer.lineDashPattern = [2, 2]
        dotterLayer.lineWidth = 2.0
        dotterLayer.frame = rect
        dotterLayer.fillColor = nil
        dotterLayer.path = UIBezierPath(rect: rect).cgPath
        signImage.layer.addSublayer(dotterLayer)
    }
}
