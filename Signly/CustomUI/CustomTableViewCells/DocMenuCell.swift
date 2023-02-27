//
//  DocMenuCell.swift
//  Signly
//
//  Created by Сергей Никитин on 11.09.2022.
//

import UIKit

class DocMenuCell: BaseTableCell {

    weak var delegate: MainViewController?
    var model: DocumentMenuModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        
        backView.viewTouched {
            delegate.menuAction(model: model)
        }
    }
}

extension DocMenuCell {
    
    func configure(model: DocumentMenuModel) {
        self.model = model
        self.backgroundColor = .clear
        
        backView.backgroundColor = .clear
        
        menuImage.image = model.icon
        menuImage .tintColor = .appSystemColor
        
        menuLabel.text = model.title
        menuLabel.textColor = .appDarkTextColor
        menuLabel.font = .appBodyText
    }
}
