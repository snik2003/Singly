//
//  SuccessSigningViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit

class SuccessSigningViewController: BaseViewController {

    weak var delegate: SigningViewController?
    var document: PDFDocumentModel?
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var shareButton: WhiteButton!
    @IBOutlet weak var closeButton: WhiteButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
    
    @IBAction func shareButtonAction() {
        guard let delegate = self.delegate else { return }
        guard let document = self.document else { return }
        
        shareButton.viewTouched {
            self.dismiss(animated: false) {
                delegate.shareAfterSuccessSigning(document)
            }
        }
    }
    
    @IBAction func closeButtonAction() {
        guard let delegate = delegate else { return }
        
        closeButton.viewTouched {
            self.dismiss(animated: false) {
                delegate.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func setupInitialState() {
        view.backgroundColor = UIColor(red: 0.333, green: 0.29, blue: 0.941, alpha: 0.82)
        
        titleLabel.text = "singing.screen.success.signed.document.title.text".localized()
        titleLabel.textColor = .white
        titleLabel.font = .appHeadline1
        
        subtitleLabel.text = "singing.screen.success.signed.document.subtitle.text".localized()
        subtitleLabel.textColor = .white
        subtitleLabel.font = .appHeadline3
        
        shareButton.setTitle("singing.screen.success.signed.document.share.button.title".localized(), for: .normal)
        closeButton.setTitle("singing.screen.success.signed.document.close.button.title".localized(), for: .normal)
    }
}
