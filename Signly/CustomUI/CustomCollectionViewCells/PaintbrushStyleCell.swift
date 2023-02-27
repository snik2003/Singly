//
//  PaintbrushStyleCell.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class PaintbrushStyleCell: BaseCollectionViewCell {

    weak var delegate: FormPaintbrushCell?
    
    var model: PaintbrushStyleModel?
    var isModelSelected = false
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let model = self.model else { return }
        guard let delegate = delegate else { return }
        guard let controller = delegate.delegate else { return }
        guard let form = controller.focusedForm else { return }
        
        iconView.viewTouched {
            if PaintbrushSettings.shared.style.contains(model) {
                PaintbrushSettings.shared.style.removeAll(where: { $0 == model })
            } else {
                PaintbrushSettings.shared.style.append(model)
            }
            
            controller.presenter?.savePaintbrushStyleSettings()
            delegate.collectionView.reloadData()
            
            if form.type == .text {
                form.textField.font = PaintbrushSettings.shared.currentFont()
                form.prepareAfterEditTextField(text: form.signText, showMenu: false)
            } else if form.type == .date {
                form.textField.font = PaintbrushSettings.shared.currentFont()
                form.prepareAfterEditDate(showMenu: false)
            }
        }
    }
}

extension PaintbrushStyleCell {
    
    func configure(model: PaintbrushStyleModel) {
        self.model = model
        
        iconView.image = model.icon
        iconView.tintColor = PaintbrushSettings.shared.style.contains(model) ? .appSystemColor : .appSystemColor30
    }
}
