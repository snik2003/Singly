//
//  InstructionViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol InstructionViewInput: BaseViewInput {
    func setupInitialState()
}

final class InstructionViewController: BaseViewController {

    var presenter: InstructionViewOutput?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }

    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension InstructionViewController: InstructionViewInput {
    
    func setupInitialState() {
        backView.backgroundColor = .appSystemColor
        titleLabel.text = "another.app.screen.header.label.title".localized()
        titleLabel.textColor = .appDarkTextColor
        titleLabel.font = .appHeadline2
        
        setupIconSize()
    }
    
    func setupIconSize() {
        let aspect = iconAspectRatioConstraint.multiplier
        let height = UIScreen.main.bounds.height - 124 - 2 * iconTopConstraint.constant
        let width = UIScreen.main.bounds.width - 2 * iconLeadingConstraint.constant
        
        guard width / height >= aspect else { return }
        
        if iconTopConstraint.constant == 80 {
            iconTopConstraint.constant = 40
            setupIconSize()
        } else {
            iconLeadingConstraint.constant = 50
        }
    }
}
