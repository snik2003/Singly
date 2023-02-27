//
//  PreviewViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol PreviewViewInput: BaseViewInput {
    func setupInitialState(document: DocumentModel)
}

final class PreviewViewController: BaseViewController {

    var presenter: PreviewViewOutput?
    var needToCrop = false
    
    var document: DocumentModel!
    var dataSource: [UIImage] = []
    
    var selectedPage = 0
    
    var upgradeView = UpgradeView()
    var filter: FilterModel = .original
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var backPageView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        needToCropAction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        upgradeView.hideUpgradeView(animated: false)
    }
    
    @IBAction func closeButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonAction() {
        guard let navigationController = self.navigationController else { return }
        
        doneButton.viewTouched {
            let controller = SigningModuleConfigurator.instantiateModule(document: self.document)
            navigationController.popViewController(animated: false)
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func filterButtonAction() {
        filterButton.viewTouched {
            let controller = FilterModuleConfigurator.instantiateModule(page: self.document.pages[self.selectedPage])
            controller.delegate = self
            controller.filter = self.filter
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func cropButtonAction() {
        guard let image = pageView.image else { return }
        
        cropButton.viewTouched {
            let controller = CropViewController()
            controller.delegate = self
            controller.originalImage = image
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func needToCropAction() {
        guard needToCrop else { return }
        needToCrop = false
        
        guard let image = pageView.image else { return }
        
        let controller = CropViewController()
        controller.delegate = self
        controller.originalImage = image
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func rotateButtonAction() {
        rotateButton.viewTouched {
            let message = "preview.screen.rotate.page.menu.message.text".localized()
            
            let title1 = "preview.screen.rotate.page.rotate.90.left.text".localized()
            let title2 = "preview.screen.rotate.page.rotate.90.right.text".localized()
            let title3 = "preview.screen.rotate.page.custom.angle.text".localized()
            
            self.showThreeActionsAlert(nil, message: message, title1: title1, title2: title2, title3: title3, actionType3: .ok,
            comp1: {
                self.rotateAngle("-90")
            },
            comp2: {
                self.rotateAngle("90")
            },
            comp3: {
                self.alertForRotateAngle()
            })
        }
    }
    
    func rotateAngle(_ value: String) {
        guard let angle = Double(value) else {
            showAttentionMessage("preview.screen.rotate.alert.error.text".localized())
            return
        }
        
        guard let image = document.pages[selectedPage].rotate(radians: Float(angle * Double.pi) / 180) else {
            showAttentionMessage("preview.screen.rotate.alert.error.text".localized())
            return
        }
        
        document.updateDate = Date()
        document.pages[selectedPage] = image
        pageView.image = image
        reloadData()
    }
    
    func alertForRotateAngle() {
        let message = "preview.screen.rotate.alert.message.text".localized()
        let doneTitle = "preview.screen.rotate.alert.done.action.text".localized()
        let cancelTitle = "preview.screen.rotate.alert.cancel.action.text".localized()
        let placeholder = "preview.screen.rotate.alert.placeholder.text".localized()
        
        showTextFieldAlert(nil, message: message, doneTitle: doneTitle, cancelTitle: cancelTitle,
                           startValue: "", placeholder: placeholder, keyboardType: .numberPad) { value in
            self.rotateAngle(value)
        }
    }
    
    @IBAction func deleteButtonAction() {
        deleteButton.viewTouched {
            guard self.presenter?.isPremium() == true else {
                self.showAttentionMessage("preview.screen.delete.single.page.error.text".localized())
                return
            }
            
            guard self.document.pages.count > 1 else {
                self.showAttentionMessage("preview.screen.delete.single.page.error.text".localized())
                return
            }
            
            let message = "preview.screen.delete.page.confirm.text".localized()
            let title1 = "common.yes.button.alert".localized()
            let title2 = "common.cancel.button.alert".localized()
            
            self.showCustomYesNoAlert(nil, message: message, title1: title1, title2: title2, comp1: {
                
                self.document.updateDate = Date()
                self.document.pages.remove(at: self.selectedPage)
                self.selectedPage = self.selectedPage < self.document.pages.count ? self.selectedPage : self.selectedPage - 1
                self.pageView.image = self.document.pages[self.selectedPage]
                self.reloadData()
                
            }, comp2: {})
        }
    }
    
    func selectPageAtIndex(_ index: Int) {
        guard let presenter = presenter else { return }
        guard index < document.pages.count else { return }
        
        upgradeView.hideUpgradeView() {
            if index > 0 && !presenter.isPremium() {
                let point = self.pageView.convert(self.pageView.bounds, to: self.view).minY
                self.upgradeView.showUpgradeView(at: point)
                return
            }
            
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            self.selectedPage = index
            self.pageView.image = self.document.pages[index]
            self.reloadData()
        }
    }
    
    func addPage() {
        upgradeView.hideUpgradeView() {
            guard self.presenter?.isPremium() == true else {
                let point = self.pageView.convert(self.pageView.bounds, to: self.view).minY
                self.upgradeView.showUpgradeView(at: point)
                return
            }
            
            let index = self.document.pages.count
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            let controller = ImportModuleConfigurator.instantiateModule()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension PreviewViewController: PreviewViewInput {
    
    func setupInitialState(document: DocumentModel) {
        self.document = document
        
        nameLabel.text = document.filename
        nameLabel.textColor = .appDarkTextColor
        nameLabel.font = .appHeadline2
        
        dateLabel.text = presenter?.documentDate()
        dateLabel.textColor = .appDarkTextColor30
        dateLabel.font = .appHintText
        
        doneButton.setTitle("preview.screen.done.button.title".localized(), for: .normal)
        doneButton.setTitleColor(.appSystemColor, for: .normal)
        doneButton.titleLabel?.font = .appHeadline3
        
        toolView.backgroundColor = .appSystemColor10
        pageView.image = document.pages[0]
        
        upgradeView = UpgradeView()
        upgradeView.upgradeMessage = "upgrade.view.multipaging.message.text".localized()
        upgradeView.actionMessage = "upgrade.view.action.title".localized()
        upgradeView.delegate = self
        upgradeView.configure()
        upgradeView.hideUpgradeView()
        
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectPageCell.self)
    }
    
    func reloadData() {
        dataSource = document.pages
        
        let maxWidth = UIScreen.main.bounds.width
        let width = 80.0 * CGFloat(dataSource.count + 1)
        
        collectionViewLeadingConstraint.constant = width < maxWidth - 32 ? (maxWidth - width) / 2 : 16
        collectionView.reloadData()
    }
}

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < dataSource.count {
            let cell: SelectPageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let index = indexPath.item
            cell.configure(index: index, page: document.pages[index], current: index == selectedPage)
            
            return cell
        } else {
            let cell: SelectPageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            cell.configureForAddPage()
            
            return cell
        }
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 80, height: 104)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let inset = (collectionView.bounds.height - 104) / 2
        return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }
}
