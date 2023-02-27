//
//  MainViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

protocol MainViewInput: BaseViewInput {
    func setupInitialState()
}

final class MainViewController: BaseViewController {

    var presenter: MainViewOutput?
    var documents: [PDFDocumentModel] = []
    
    private var menuDataSource: [DocumentMenuModel] = DocumentMenuModel.allCases.filter({ $0.isActive })
    private var menuDocument: PDFDocumentModel?
    
    var cachedIcons: [String: UIImage] = [:]
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var menuTableView: UITableView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var pulseView1: UIView!
    @IBOutlet weak var pulseView2: UIView!
    @IBOutlet weak var pulseView3: UIView!
    
    @IBOutlet weak var docMenuImage: UIImageView!
    @IBOutlet weak var docMenuImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var docMenuImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var docMenuNameLabel: UILabel!
    @IBOutlet weak var docMenuDateLabel: UILabel!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var upgradeView = UpgradeView()
    
    var firstAppear = true
    var repeatsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playPulseAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPulseAnimation()
    }
    
    @IBAction func settingsButtonAction() {
        settingsButton.viewTouched {
            let controller = SettingsModuleConfigurator.instantiateModule()
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @IBAction func plusButtonAction() {
        plusButton.viewTouched {
            self.stopPulseAnimation()
            let controller = ImportModuleConfigurator.instantiateModule()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showDocumentMenu(document: PDFDocumentModel, completion: EmptyBlock? = nil) {
        menuDocument = document
        updateDocMenuView()
        reloadMenuData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blockView.alpha = 1.0
            self.menuViewBottomConstraint.constant = 10
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func hideDocumentMenu(completion: EmptyBlock? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
            self.blockView.alpha = 0.0
            self.menuViewBottomConstraint.constant = self.menuViewHeightConstraint.constant + 10
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func menuAction(model: DocumentMenuModel) {
        guard let presenter = presenter else { return }

        hideDocumentMenu() {
            switch model {
            case .sign:
                self.signDocument()
            case .share:
                guard presenter.isPremium() || presenter.isFirstShare() else {
                    self.openPaywall()
                    return
                }
                
                self.shareDocument(self.menuDocument)
            case .rename:
                self.renameDocument()
            case .preview:
                self.previewMenuDocument()
            case .dublicate:
                self.dublicateDocument()
            case .delete:
                self.deleteMenuDocument()
            }
        }
    }
    
    func signDocument() {
        guard let menuDocument = menuDocument else { return }
        
        let filename = signedDocumentTitle(for: menuDocument, of: documents)
        let document = DocumentModel(document: menuDocument, filename: filename)
        let controller = PreviewModuleConfigurator.instantiateModule(document: document)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func renameDocument() {
        guard let document = menuDocument else { return }
        
        let title: String? = nil //"main.screen.rename.document.alert.title.text".localized()
        let message = "main.screen.rename.document.alert.message.text".localized()
        
        let doneTitle = "main.screen.rename.document.alert.rename.action.text".localized()
        let cancelTitle = "main.screen.rename.document.alert.cancel.action.text".localized()
        
        let placeholder = "main.screen.rename.document.alert.placeholder.text".localized()
        
        let currentValue = document.filename
        showTextFieldAlert(title, message: message, doneTitle: doneTitle, cancelTitle: cancelTitle,
                           startValue: currentValue, placeholder: placeholder) { newValue in
            
            document.filename = newValue
            self.showLoading(withTitle: "main.screen.rename.document.loading.title".localized())
            
            var images: [UIImage] = []
            for data in document.publishPages {
                guard let image = PDFDocumentModel.convertDataToImage(data: data) else { continue }
                images.append(image)
            }
            
            PDFManager.shared.createPDF(from: images, withName: newValue) { _, data, errorMessage in
                if let errorMessage = errorMessage {
                    self.hideLoading()
                    self.showAttentionMessage(errorMessage)
                    document.filename = currentValue
                    return
                }
                
                document.finalData = data ?? document.finalData
                self.presenter?.saveDocumentModel(document) { error in
                    if let error = error {
                        self.hideLoading()
                        self.showAttentionMessage(error)
                        document.filename = currentValue
                        return
                    }
                    
                    self.reloadDataWithoutRequest()
                    self.hideLoading()
                }
            }
        }
    }
    
    func previewMenuDocument() {
        guard let document = menuDocument else { return }
        PDFManager.shared.openPDF(withData: document.finalData, andName: document.filename, in: self)
    }
    
    func dublicateDocument() {
        guard let document = menuDocument else { return }
        
        let newFilename = dublicateDocumentTitle(for: document, of: self.documents)
        let copyDocument = PDFDocumentModel(document: document, newFilename: newFilename)
    
        showLoading(withTitle: "main.screen.dublicate.document.loading.title".localized())
        presenter?.saveDocumentModel(copyDocument) { error in
            guard let error = error else {
                self.documents.insert(copyDocument, at: 0)
                self.cachedIcons[copyDocument.documentId] = self.cachedIcons[document.documentId]
                Constants.shared.needUpdateRequest = true
                self.reloadData()
                self.hideLoading()
                return
            }
            
            self.hideLoading()
            self.showAttentionMessage(error)
        }
    }
    
    func deleteMenuDocument() {
        guard let presenter = presenter else { return }
        guard let document = menuDocument else { return }

        let message = "main.screen.delete.document.confirmation.message.text".localized()
        let title1 = "common.yes.button.alert".localized()
        let title2 = "common.cancel.button.alert".localized()
        
        self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
            self.showLoading(withTitle: "main.screen.deleting.document.loading.title".localized())
            presenter.deleteDocumentModel(document.documentId) { error in
                guard let error = error else {
                    self.documents = self.documents.filter({ $0.documentId != document.documentId })
                    self.cachedIcons.removeValue(forKey: document.documentId)
                    self.reloadDataWithoutRequest()
                    self.hideLoading()
                    return
                }
            
                self.hideLoading()
                self.showAttentionMessage(error)
            }
        }, comp2: {})
    }
}

extension MainViewController: MainViewInput {
    
    func setupInitialState() {
        blockView.alpha = 0.0
        blockView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        menuView.alpha = 1.0
        menuView.clipsToBounds = true
        menuView.layer.cornerRadius = 12
        menuView.backgroundColor = .white
        menuViewHeightConstraint.constant = CGFloat(196 + menuDataSource.count * 48)
        menuViewBottomConstraint.constant = menuViewHeightConstraint.constant - 10
        menuView.dropShadow(color: .appDarkTextColor60, opacity: 0.5, offSet: CGSize(width: 0.3, height: 0.3), radius: 12, scale: false)
        
        setupTapCloseMenu()
        setupSwipeCloseMenu()
        
        titleLabel.text = "main.screen.header.label.title".localized()
        titleLabel.textColor = .appDarkTextColor
        titleLabel.font = .appHeadline1
        
        homeButton.isEnabled = false
        homeButton.setTitle("main.screen.tabbar.home.button.title".localized(), for: .normal)
        homeButton.setTitleColor(.appDarkTextColor, for: .normal)
        homeButton.titleLabel?.font = .appHintText2
        
        settingsButton.setTitle("main.screen.tabbar.settings.button.title".localized(), for: .normal)
        settingsButton.setTitleColor(.appDarkTextColor60, for: .normal)
        settingsButton.titleLabel?.font = .appHintText2
        
        pulseView1.backgroundColor = .appSystemColor30
        pulseView1.layer.cornerRadius = 36
        pulseView1.layer.opacity = 0.0
        
        pulseView2.backgroundColor = .appSystemColor30
        pulseView2.layer.cornerRadius = 44
        pulseView2.layer.opacity = 0.0
        
        pulseView3.backgroundColor = .appSystemColor30
        pulseView3.layer.cornerRadius = 52
        pulseView3.layer.opacity = 0.0
        
        plusButton.backgroundColor = .appSystemColor
        plusButton.layer.cornerRadius = 28
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DocumentCell.self)
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(DocumentCell.self)
        menuTableView.register(DocMenuCell.self)
        
        upgradeView = UpgradeView()
        upgradeView.headerMessage = "paywall.banner.title.text".localized()
        upgradeView.upgradeMessage = nil
        upgradeView.actionMessage = "paywall.banner.subtitle.text".localized()
        upgradeView.animateHideWhileAction = false
        upgradeView.delegate = self
        upgradeView.configure()
        upgradeView.hideUpgradeView()
    }
    
    func updateDocMenuView() {
        guard let menuDocument = menuDocument else { return }
        
        self.docMenuImage.image = cachedIcons[menuDocument.documentId] ?? menuDocument.icon
        self.docMenuImage.clipsToBounds = true
        self.docMenuImage.layer.cornerRadius = 10
        self.docMenuImage.layer.borderWidth = 0.8
        self.docMenuImage.layer.borderColor = UIColor.appDarkTextColor60.cgColor
        
        self.docMenuNameLabel.text = menuDocument.filename
        self.docMenuNameLabel.textColor = .appDarkTextColor
        self.docMenuNameLabel.font = .appHeadline3
        
        self.docMenuDateLabel.text = DocumentCell.dateFormatter.string(from: menuDocument.updateDate)
        self.docMenuDateLabel.textColor = .appDarkTextColor60
        self.docMenuDateLabel.font = .appHintText
    }
    
    func reloadData() {
        guard Constants.shared.needUpdateRequest else {
            reloadDataWithoutRequest()
            return
        }
        
        Constants.shared.needUpdateRequest = false
        showLoading(withTitle: "main.screen.loading.documents.loading.title".localized())
        presenter?.loadDocuments() { documents in
            self.documents = documents ?? []
            self.reloadDataWithoutRequest()
            self.tableView.scrollToTop(animated: true)
            self.hideLoading()
        }
    }
    
    func reloadDataWithoutRequest() {
        tableView.reloadData()
        
        if presenter?.isPremium() == true {
            upgradeView.hideUpgradeView(animated: false)
            tableViewTopConstraint.constant = 0
        } else {
            upgradeView.showUpgradeView(at: 125, animated: false)
            tableViewTopConstraint.constant = upgradeView.bounds.height
        }
    }
    
    func reloadMenuData() {
        menuTableView.reloadData()
    }
    
    func setupTapCloseMenu() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(gestureHandler))
        blockView.addGestureRecognizer(tap)
    }
    
    func setupSwipeCloseMenu() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .down
        swipe.addTarget(self, action: #selector(gestureHandler))
        menuView.addGestureRecognizer(swipe)
    }
    
    @objc func gestureHandler() {
        hideDocumentMenu()
    }
    
    func stopPulseAnimation() {
        firstAppear = false
        pulseView1.layer.removeAllAnimations()
        pulseView2.layer.removeAllAnimations()
        pulseView3.layer.removeAllAnimations()
        repeatsCount = Constants.shared.maxPulseAnimationCount
    }
    
    func playPulseAnimation() {
        guard documents.count == 0 else { return }
        guard firstAppear else { return }
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            self.repeatsCount += 1
            guard self.repeatsCount <= Constants.shared.maxPulseAnimationCount else {
                self.stopPulseAnimation()
                return
            }
            
            self.pulseView1.layer.opacity = 0.0
            self.pulseView2.layer.opacity = 0.0
            self.pulseView3.layer.opacity = 0.0
            self.playPulseAnimation()
        })
        
        plusButton.shake()
        
        let pulseAnimation1 = CABasicAnimation(keyPath: "opacity")
        pulseAnimation1.duration = 1.0
        pulseAnimation1.fromValue = 0
        pulseAnimation1.toValue = 1
        pulseAnimation1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation1.autoreverses = false
        pulseView1.layer.add(pulseAnimation1, forKey: nil)
        
        let pulseAnimation2 = CABasicAnimation(keyPath: "opacity")
        pulseAnimation2.duration = 1.5
        pulseAnimation2.fromValue = 0
        pulseAnimation2.toValue = 1
        pulseAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation2.autoreverses = false
        pulseView2.layer.add(pulseAnimation2, forKey: nil)
        
        let pulseAnimation3 = CABasicAnimation(keyPath: "opacity")
        pulseAnimation3.duration = 1.8
        pulseAnimation3.fromValue = 0
        pulseAnimation3.toValue = 1
        pulseAnimation3.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation3.autoreverses = true
        pulseView3.layer.add(pulseAnimation3, forKey: nil)
        
        CATransaction.commit()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == menuTableView else { return documents.count }
        return menuDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == menuTableView else { return 100 }
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == menuTableView {
            let cell: DocMenuCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: menuDataSource[indexPath.row])
            return cell
        } else {
            let cell: DocumentCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(document: documents[indexPath.row], icon: cachedIcons[documents[indexPath.row].documentId])
            return cell
        }
    }
}
