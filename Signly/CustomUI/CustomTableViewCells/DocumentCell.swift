//
//  DocumentCell.swift
//  Signly
//
//  Created by Сергей Никитин on 10.09.2022.
//

import UIKit

class DocumentCell: BaseTableCell {

    weak var delegate: MainViewController?
    var document: PDFDocumentModel?
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy',' HH:mm"
        return dateFormatter
    }
    
    @IBOutlet weak var docImage: UIImageView!
    @IBOutlet weak var docImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var docImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var docImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docDateLabel: UILabel!
    @IBOutlet weak var docButton: UIButton!
    
    @IBAction func docButtonAction() {
        guard let delegate = delegate else { return }
        guard let document = document else { return }
        
        docButton.viewTouched {
            delegate.showDocumentMenu(document: document)
        }
    }
}

extension DocumentCell {
    
    func configure(document: PDFDocumentModel, icon: UIImage? = nil) {
        self.document = document
        self.backgroundColor = .clear
        
        if let icon = icon {
            self.docImage.image = icon
        } else if let delegate = delegate, let icon = document.icon {
            self.docImage.image = icon
            delegate.cachedIcons[document.documentId] = icon
        }
        
        self.docImage.clipsToBounds = true
        self.docImage.layer.cornerRadius = 10
        self.docImage.layer.borderWidth = 0.8
        self.docImage.layer.borderColor = UIColor.appDarkTextColor60.cgColor
        
        self.docNameLabel.text = document.filename
        self.docNameLabel.textColor = .appDarkTextColor
        self.docNameLabel.font = .appHeadline3
        
        self.docDateLabel.text = DocumentCell.dateFormatter.string(from: document.updateDate)
        self.docDateLabel.textColor = .appDarkTextColor60
        self.docDateLabel.font = .appHintText
        
        self.layoutIfNeeded()
    }
}
