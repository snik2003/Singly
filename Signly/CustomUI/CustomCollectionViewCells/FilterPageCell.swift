//
//  FilterPageCell.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

class FilterPageCell: BaseCollectionViewCell {

    weak var delegate: FilterViewController?
    weak var image: UIImage?
    
    var model: FilterModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        
        backView.viewTouched {
            delegate.filter = model
            delegate.reloadData()
        }
    }
}

extension FilterPageCell {
    
    func configure(model: FilterModel, selected: Bool = false, value: Float? = nil) {
        self.model = model
        
        pageView.clipsToBounds = true
        pageView.layer.cornerRadius = 12
        pageView.layer.borderWidth = selected ? 2.0 : 1.0
        pageView.layer.borderColor = selected ? UIColor.appSystemColor.cgColor : UIColor.appSystemColor30.cgColor
        
        backView.backgroundColor = .clear
        
        label.text = model.title
        label.textColor = .appDarkTextColor
        label.font = .appHintText2
        
        guard let delegate = delegate else { return }
        guard let image = self.image else { return }
        
        let filterImage = model.image(image, value: value) ?? image
        pageView.image = filterImage
        
        guard selected else { return }
        delegate.pageView.image = filterImage
    }
}
