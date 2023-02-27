//
//  SettingsViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

protocol SettingsViewInput: BaseViewInput {
    func setupInitialState()
}

final class SettingsViewController: BaseViewController {

    var presenter: SettingsViewOutput?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var upgradeView = UpgradeView()
    var dataSource: [SettingsModel] = SettingsModel.allCases
    
    var signatureModel: SignatureModel?
    var initialsModel: SignatureModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func homeButtonAction() {
        homeButton.viewTouched {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func addSignature() {
        openAddSignature(type: .signature)
    }
    
    func editSignature() {
        openAddSignature(type: .signature, model: signatureModel)
    }
    
    func deleteSignature() {
        var message = "add.signature.screen.delete.confirmation.message.text".localized()
        message = message.replacingOccurrences(of: "$DRAW_TYPE$", with: "your signature")
        
        let title1 = "common.yes.button.alert".localized()
        let title2 = "common.cancel.button.alert".localized()
        
        self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
            if let error = self.presenter?.deleteSignatureModel(.signature) {
                self.showAttentionMessage(error)
            } else {
                self.reloadData()
            }
        }, comp2: {})
    }
    
    func addInititals() {
        openAddSignature(type: .initials)
    }
    
    func editInitials() {
        openAddSignature(type: .initials, model: initialsModel)
    }
    
    func deleteInitials() {
        var message = "add.signature.screen.delete.confirmation.message.text".localized()
        message = message.replacingOccurrences(of: "$DRAW_TYPE$", with: "your initials")
        
        let title1 = "common.yes.button.alert".localized()
        let title2 = "common.cancel.button.alert".localized()
        
        self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
            if let error = self.presenter?.deleteSignatureModel(.initials) {
                self.showAttentionMessage(error)
            } else {
                self.reloadData()
            }
        }, comp2: {})
    }
}

extension SettingsViewController: SettingsViewInput {
    
    func setupInitialState() {
        titleLabel.text = "settings.screen.header.label.title".localized()
        titleLabel.textColor = .appDarkTextColor
        titleLabel.font = .appHeadline1
        
        homeButton.setTitle("main.screen.tabbar.home.button.title".localized(), for: .normal)
        homeButton.setTitleColor(.appDarkTextColor60, for: .normal)
        homeButton.titleLabel?.font = .appHintText2
        
        settingsButton.isEnabled = false
        settingsButton.setTitle("main.screen.tabbar.settings.button.title".localized(), for: .normal)
        settingsButton.setTitleColor(.appDarkTextColor, for: .normal)
        settingsButton.titleLabel?.font = .appHintText2
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PremiumCell.self)
        tableView.register(SettingsTextFieldCell.self)
        tableView.register(SettingsCustomCell.self)
        tableView.register(SettingsButtonCell.self)
        
        upgradeView = UpgradeView()
        upgradeView.headerMessage = "paywall.banner.title.text".localized()
        upgradeView.upgradeMessage = nil
        upgradeView.actionMessage = "paywall.banner.subtitle.text".localized()
        upgradeView.animateHideWhileAction = false
        upgradeView.delegate = self
        upgradeView.configure()
        upgradeView.hideUpgradeView()
    }
    
    func reloadData() {
        signatureModel = presenter?.loadSignatureModelFor(.signature)
        initialsModel = presenter?.loadSignatureModelFor(.initials)
        
        tableView.reloadData()
        
        if presenter?.isPremium() == true {
            upgradeView.hideUpgradeView(animated: false)
            tableViewTopConstraint.constant = 0
        } else {
            upgradeView.showUpgradeView(at: 125, animated: false)
            tableViewTopConstraint.constant = self.upgradeView.bounds.height
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataSource.filter({ $0.type == .textField }).count
        case 1:
            return dataSource.filter({ $0.type == .custom }).count
        case 2:
            return dataSource.filter({ $0.type == .disclosureButton }).count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let models = dataSource.filter({ $0.type == .textField })
            return models[indexPath.row].rowHeight
        case 1:
            
            let models = dataSource.filter({ $0.type == .custom })
            let model = models[indexPath.row]
            
            if model == .signature && signatureModel != nil { return (UIScreen.main.bounds.width - 32) / 2 + 53 }
            if model == .initials && initialsModel != nil { return (UIScreen.main.bounds.width - 32) / 2 + 53 }
            
            return model.rowHeight
        case 2:
            let models = dataSource.filter({ $0.type == .disclosureButton })
            return models[indexPath.row].rowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let models = dataSource.filter({ $0.type == .textField })
            let model = models[indexPath.row]
            
            let cell: SettingsTextFieldCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            var value: String? = nil
            if model == .name { value = presenter?.nameValue() }
            if model == .email { value = presenter?.emailValue() }
            if model == .company { value = presenter?.companyValue() }
            
            cell.configure(model: model, value: value)
            return cell
        case 1:
            let models = dataSource.filter({ $0.type == .custom })
            let model = models[indexPath.row]
            
            let cell: SettingsCustomCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model, signature: model == .signature ? signatureModel : initialsModel)
            
            return cell
        case 2:
            let models = dataSource.filter({ $0.type == .disclosureButton })
            let model = models[indexPath.row]
            
            let cell: SettingsButtonCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
