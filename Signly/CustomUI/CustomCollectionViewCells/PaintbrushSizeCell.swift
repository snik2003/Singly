//
//  PaintbrushSizeCell.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class PaintbrushSizeCell: BaseCollectionViewCell {

    weak var delegate: FormPaintbrushCell?
    
    var value: CGFloat?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let value = self.value else { return }
        guard let delegate = delegate else { return }
        guard let controller = delegate.delegate else { return }
        guard let form = controller.focusedForm else { return }
        
        backView.viewTouched {
            PaintbrushSettings.shared.size = value
            controller.presenter?.savePaintbrushSizeSettings()
            delegate.collectionView.reloadData()
            delegate.scrollCollectionView()
            
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

extension PaintbrushSizeCell {
    
    func configure(value: CGFloat) {
        self.value = value
        
        label.text = String(Int(value))
        label.textColor = PaintbrushSettings.shared.size == value ? .appSystemColor : .appSystemColor30
        label.font = .appHeadline1
    }
}
