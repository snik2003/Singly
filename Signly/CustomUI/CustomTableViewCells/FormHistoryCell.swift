//
//  FormHistoryCell.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class FormHistoryCell: BaseTableCell {

    weak var delegate: SigningViewController?
    var model: HistoryCacheModel?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var backView: UIView!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        guard let form = delegate.focusedForm else { return }
        
        backView.viewTouched {
            form.textField.text = model.text
            form.updateTextField(text: model.text)
            form.prepareAfterEditTextField(text: model.text, showMenu: false)
        }
    }
    
    @IBAction func clearButtonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        
        clearButton.viewTouched {
            delegate.presenter?.removeFromHistoryCache(model)
            delegate.dataSource2 = TextFormModel.history.dataSource(delegate.presenter)
            delegate.textTableView.reloadData()
        }
    }
}

extension FormHistoryCell {
    
    func configure(model: HistoryCacheModel) {
        self.model = model
        self.backgroundColor = .clear
        backView.backgroundColor = .clear
        
        label.text = model.text
        label.textColor = .appDarkTextColor
        label.font = .appHeadline3
        
        dateLabel.text = DocumentCell.dateFormatter.string(from: model.date)
        dateLabel.textColor = .appDarkTextColor60
        dateLabel.font = .appHintText2
    }
}
