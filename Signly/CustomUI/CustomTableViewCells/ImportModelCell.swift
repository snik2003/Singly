//
//  ImportModelCell.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

class ImportModelCell: BaseTableCell {

    weak var delegate: ImportViewController?
    var model: ImportModel?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        backView.viewTouched {
            switch model {
            case .scan:
                delegate.startScanner()
            case .photos:
                delegate.openPhotos()
            case .files:
                delegate.openFiles()
            case .email, .other:
                delegate.openAnotherAppInstruction()
            }
        }
    }
}

extension ImportModelCell {
    
    func configure(model: ImportModel) {
        self.model = model
        
        self.icon.image = model.image
        self.label.text = model.title
        self.label.textColor = .appDarkTextColor
        self.label.font = .appBodyText
    }
}
