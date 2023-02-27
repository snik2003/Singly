//
//  PaywallViewController.swift
//  BeforeAfter
//
//  Created by Сергей Никитин on 18.07.2022.
//

import UIKit
import StoreKit
import ApphudSDK

protocol PaywallViewInput: BaseViewInput {
    func setupInitialState()
}

final class PaywallViewController: BaseViewController {

    let defaultItem: Int = 1
    let popularItem: Int = 1
    
    var presenter: PaywallViewOutput?
    var isOnboard = false
    
    var products: [SKProduct] = Constants.shared.storeProducts
    var selectedProduct: ApphudProduct?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var continueButton: BlueButton!
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var benefit1Label: UILabel!
    @IBOutlet weak var benefit2Label: UILabel!
    @IBOutlet weak var benefit3Label: UILabel!
    
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateModel()
    }
    
    @IBAction func backButtonAction() {
        if isOnboard {
            navigationController?.popViewController(animated: false)
        } else {
            closeViewControllerAction()
        }
    }
    
    @IBAction func closeButtonAction() {
        setupRootViewController(isOnboard: self.isOnboard)
    }
    
    @IBAction func continueButtonAction() {
        guard let presenter = presenter else { return }
        
        continueButton.viewTouched {
            guard !Constants.shared.isTestMode else {
                presenter.setPremiumMode(true)
                self.setupRootViewController(isOnboard: self.isOnboard)
                return
            }
            
            guard let product = self.selectedProduct else { return }
            
            self.showLoading()
            Apphud.purchase(product) { result in
                self.hideLoading()
                
                if let error = result.error {
                    self.showAttentionMessage(error.localizedDescription)
                } else if let subscription = result.subscription, subscription.isActive() {
                    presenter.setPremiumMode(Apphud.hasActiveSubscription())
                    self.setupRootViewController(isOnboard: self.isOnboard)
                } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                    presenter.setPremiumMode(Apphud.hasActiveSubscription())
                    self.setupRootViewController(isOnboard: self.isOnboard)
                } else {
                    self.showAttentionMessage("paywall.product.cancel.purchase.message.text".localized())
                }
            }
        }
    }
    
    @IBAction func restoreButtonAction() {
        self.restorePurchases()
    }
    
    @IBAction func termsButtonAction() {
        self.openTermsOfUse()
    }
    
    @IBAction func privacyButtonAction() {
        self.openPrivacyPolicy()
    }
}

extension PaywallViewController: PaywallViewInput {
    
    func setupInitialState() {
        self.view.backgroundColor = .white
        self.backButton.alpha = isOnboard ? 1.0 : 0.0
        self.gradientView.gradientBackgroundColor(color1: .appGradientColor1, color2: .appGradientColor2)
        
        self.iconView.backgroundColor = UpgradeView.color1
        self.iconView.layer.cornerRadius = 24
        self.iconView.clipsToBounds = true
        self.iconView.alpha = 0.0
        
        self.continueButton.isEnabled = false
        self.continueButton.setTitle("paywall.screen.purchase.premium.button.title".localized(), for: .normal)
        
        self.restoreButton.setTitle("paywall.screen.restore.purchases.button.title".localized(), for: .normal)
        self.restoreButton.setTitleColor(.appSystemColor80, for: .normal)
        self.restoreButton.titleLabel?.font = .appHintText
        
        self.termsButton.setTitle("paywall.screen.terms.of.use.button.title".localized(), for: .normal)
        self.termsButton.setTitleColor(.appSystemColor80, for: .normal)
        self.termsButton.titleLabel?.font = .appHintText
        
        self.privacyButton.setTitle("paywall.screen.privacy.policy.button.title".localized(), for: .normal)
        self.privacyButton.setTitleColor(.appSystemColor80, for: .normal)
        self.privacyButton.titleLabel?.font = .appHintText
        
        self.titleLabel.text = "paywall.screen.purchase.premium.title".localized()
        self.titleLabel.textColor = .appDarkTextColor
        self.titleLabel.font = .appHeadline1
        
        self.benefit1Label.text = "paywall.screen.purchase.premium.benefit1.title".localized()
        self.benefit1Label.textColor = .appDarkTextColor
        self.benefit1Label.font = .appHeadline2
        
        self.benefit2Label.text = "paywall.screen.purchase.premium.benefit2.title".localized()
        self.benefit2Label.textColor = .appDarkTextColor
        self.benefit2Label.font = .appHeadline2
        
        self.benefit3Label.text = "paywall.screen.purchase.premium.benefit3.title".localized()
        self.benefit3Label.textColor = .appDarkTextColor
        self.benefit3Label.font = .appHeadline2
        
        self.updateModel()
    }
    
    func updateModel() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ProductCell.self)
        self.collectionView.reloadData()
    }
    
    func selectDefaultItem(indexPath: IndexPath) {
        guard !continueButton.isEnabled else { return }
        guard indexPath.section == 0, indexPath.item == defaultItem else { return }
        guard products.count > defaultItem else { return }
        
        if !Constants.shared.isTestMode {
            guard Constants.shared.apphudProducts.count > defaultItem else { return }
            selectedProduct = Constants.shared.apphudProducts[defaultItem]
        } else {
            selectedProduct = nil
        }
        
        continueButton.isEnabled = true
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension PaywallViewController: UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
}

extension PaywallViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        
        if item?.isSelected ?? false {
            item?.viewTouched(duration: 0.1) {
                self.continueButton.isEnabled = false
                self.selectedProduct = nil
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        } else {
            item?.viewTouched(duration: 0.1) {
                self.continueButton.isEnabled = true
                self.selectedProduct = !Constants.shared.isTestMode ? Constants.shared.apphudProducts[indexPath.item] : nil
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
            return true
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = .clear
        
        let product = self.products[indexPath.item]
        cell.configure(product: product, isPopular: indexPath.item == popularItem)
        self.selectDefaultItem(indexPath: indexPath)
        
        return cell
    }
}

extension PaywallViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (UIScreen.main.bounds.width - 32 - 4 * 4) / 3
        let height = min(width * 1.3 + 32, collectionView.bounds.height)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let width: CGFloat = (UIScreen.main.bounds.width - 32 - 4 * 3) / 3
        let height = min(width * 1.3 + 32, collectionView.bounds.height)
        let inset = 3 * (collectionView.bounds.height - height) / 4
        
        return UIEdgeInsets(top: inset, left: 2, bottom: inset, right: 2)
    }
}
