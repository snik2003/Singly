//
//  SignBrushCell.swift
//  Signly
//
//  Created by Сергей Никитин on 07.09.2022.
//

import UIKit

class SignBrushCell: BaseCollectionViewCell {

    weak var delegate: AddSignatureViewController?
    var model: SignatureBrushModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var colorPoint: UIView!
    @IBOutlet weak var colorBrush: UIImageView!
    @IBOutlet weak var colorPointHeightConstraint: NSLayoutConstraint!
    
    @IBAction func buttonAction() {
        guard let model = self.model else { return }
        guard let delegate = delegate else { return }
        guard model != delegate.brush else { return }
        
        backView.viewTouched {
            delegate.onChangeBrushWidth(model: model)
        }
    }
}

extension SignBrushCell {
    
    func configure(model: SignatureBrushModel, color: UIColor, selected: Bool) {
        self.model = model
        
        backView.backgroundColor = .clear
        colorBrush.tintColor = selected ? color : .appDarkTextColor30
        
        colorPointHeightConstraint.constant = model.width
        colorPoint.layer.cornerRadius = model.width / 2
        colorPoint.backgroundColor = selected ? color : .appDarkTextColor30
    }
}


