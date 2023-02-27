//
//  SelectPageCell.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

class SelectPageCell: BaseCollectionViewCell {

    weak var delegate: BaseViewController?
    var pageIndex: Int?
    
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var plusIcon: UIImageView!
    
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func buttonAction() {
        if let delegate = delegate as? PreviewViewController {
            guard let pageIndex = self.pageIndex else {
                backView.viewTouched {
                    delegate.addPage()
                }
                return
            }
            
            guard pageIndex != delegate.selectedPage else { return }
            
            backView.viewTouched {
                delegate.selectPageAtIndex(pageIndex)
            }
        } else if let delegate = delegate as? SigningViewController {
            guard let pageIndex = self.pageIndex else { return }
            guard pageIndex != delegate.selectedPage else { return }
            
            backView.viewTouched {
                delegate.hidePagesView() {
                    delegate.selectPageAtIndex(pageIndex)
                }
            }
        }
    }
}

extension SelectPageCell {
    
    func reset() {
        pageIndex = nil
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 12
        backView.layer.borderColor = UIColor.appSystemColor30.cgColor
        backView.layer.borderWidth = 1.0
        backView.backgroundColor = .clear
        
        selectView.backgroundColor = .clear
        pageView.image = nil
        plusIcon.alpha = 0.0
    }
    
    func configure(index: Int, page: UIImage, current: Bool) {
        reset()
        pageIndex = index
        pageView.image = page
        
        backView.layer.borderWidth = current ? 2.0 : 1.0
        backView.layer.borderColor = current ? UIColor.appSystemColor.cgColor : UIColor.appSystemColor30.cgColor
        
        guard let delegate = delegate as? PreviewViewController, delegate.presenter?.isPremium() == false, index > 0 else { return }
        selectView.backgroundColor = .appSystemColor.withAlphaComponent(0.1)
        plusIcon.image = UIImage(named: "locked-page")
        plusIcon.alpha = 1.0
    }
    
    func configure2(index: Int, page: UIImage, current: Bool) {
        reset()
        pageIndex = index
        pageView.image = page
        
        backView.layer.borderWidth = current ? 2.0 : 1.0
        backView.layer.borderColor = current ? UIColor.appDangerousStatusColor.cgColor : UIColor.white.withAlphaComponent(0.3).cgColor
        
        guard let delegate = delegate as? SigningViewController, delegate.presenter?.isPremium() == false, index > 0 else { return }
        selectView.backgroundColor = .appSystemColor.withAlphaComponent(0.3)
        plusIcon.image = UIImage(named: "locked-page")
        plusIcon.alpha = 1.0
    }
    
    func configureForAddPage() {
        reset()
        selectView.backgroundColor = .appSystemColor10
        
        plusIcon.image = UIImage(named: "add-page")
        plusIcon.alpha = 1.0
    }
}
