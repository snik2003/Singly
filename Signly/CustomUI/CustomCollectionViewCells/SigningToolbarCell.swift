//
//  SigningToolbarCell.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

class SigningToolbarCell: BaseCollectionViewCell {

    weak var delegate: SigningViewController?
    var model: SigningToolbarModel?

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        
        delegate.selectedMenu = model
        delegate.reloadData()
        
        backView.viewTouched {
            switch model {
            case .signature:
                delegate.addSignature()
            case .initials:
                delegate.addInitials()
            case .freestyle:
                delegate.freestyle()
            case .text:
                delegate.addText()
            case .checkbox:
                delegate.addCheckbox()
            case .date:
                delegate.addDate()
            }
            
            delegate.presenter?.setupFirstSign()
            
            guard let index = SigningToolbarModel.allCases.firstIndex(of: model) else { return }
            let indexPath = IndexPath(item: index, section: 0)
            delegate.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true )
        }

    }
}

extension SigningToolbarCell {
    
    func configure(model: SigningToolbarModel, selected: Bool) {
        self.model = model
        
        backView.backgroundColor = .clear
        icon.tintColor = selected ? .appSystemColor : .appSystemColor60
        icon.image = model.image
        
        label.text = model.title
        label.textColor = selected ? .appSystemColor : .appSystemColor60
        label.font = selected ? .appUppercaseText : .appHintText
    }
}
