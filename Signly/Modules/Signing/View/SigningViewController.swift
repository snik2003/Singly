//
//  SigningViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit
import KDCalendar
import FirebaseCoreInternal
import IQKeyboardManager

protocol SigningViewInput: BaseViewInput {
    func setupInitialState(document: DocumentModel)
}

final class SigningViewController: BaseViewController {

    var presenter: SigningViewOutput?
    var model: PDFDocumentModel?
    
    var formMovingActive = false
    var firstAppear = true
    var isPreview = false
    
    var form: SignatureForm?
    
    var upgradeView = UpgradeView()
    var dataSource: [SigningToolbarModel] = SigningToolbarModel.allCases.filter({ $0.isActive == true })
    
    var document: DocumentModel!
    var selectedPage = 0
    var selectedMenu: SigningToolbarModel?
    
    var monthPicker = 0
    var selectedDate = Date()
    var selectedCheckbox: CheckboxModel = .checkmark
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pagesButton: UIButton!
    
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var backPageView: UIView!
    @IBOutlet weak var backPageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backPageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView3: UICollectionView!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolViewBootomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pagesView: UIView!
    @IBOutlet weak var pagesViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var backCalendarView: UIView!
    @IBOutlet weak var backCalendarViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var calendarView: CalendarView!
    
    @IBOutlet weak var checkboxView: UIView!
    @IBOutlet weak var checkboxViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView3LeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var brushButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var saveTextButton: UIButton!
    @IBOutlet weak var textTableView: UITableView!
    
    @IBOutlet weak var editDateStyleButton: UIButton!
    
    var animationDuration: TimeInterval!
    var animationCurve: UInt!
    
    var dataSource2: [Any] = []
    var textModel = TextFormModel.profile
    var focusedForm: SignatureForm!
    var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        presenter?.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        reloadData()
        reloadData2()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        upgradeView.hideUpgradeView(animated: false)
        hidePagesView(animated: false)
    }
    
    @IBAction func backButtonAction() {
        backButton.viewTouched {
            guard self.isPreview else {
                self.navigationController?.popViewController(animated: true)
                return
            }
        
            self.nameLabel.text = ""
            self.pagesButton.alpha = 0.0
            self.backButton.alpha = 0.0
            self.doneButton.alpha = 0.0
            
            self.pageView.image = nil
            self.removeFormsFromBackPageView()
        
            self.showLoading()
            self.hidePagesView {
                self.showToolView {
                    self.nameLabel.text = "singing.screen.header.label.title".localized()
                    self.doneButton.setTitle("signing.screen.finish.button.title".localized(), for: .normal)
                    
                    self.pagesButton.alpha = self.document.pages.count > 1 ? 1.0 : 0.0
                    self.backButton.alpha = 1.0
                    self.doneButton.alpha = 1.0
                    
                    self.isPreview = false
                    self.selectedPage = 0
                    self.selectPageAtIndex(0)
                    
                    self.hideLoading()
                }
            }
        }
    }
    
    @IBAction func doneButtonAction() {
        guard let presenter = presenter else { return }
        
        doneButton.viewTouched {
            self.upgradeView.hideUpgradeView() {
                self.prepareUpgradeView(.date)
                self.upgradeView.hideUpgradeView() {
                    guard !self.isPreview else {
                        guard presenter.isPremium() || presenter.isFirstShare() else {
                            self.showUpgradeConfirmToSaveDraft()
                            return
                        }
                        
                        self.showLoading(withTitle: "singing.screen.signing.process.loading.title".localized())
                        self.publishDocument { data in
                            guard let data = data else { return }
                            
                            self.document.updateDate = Date()
                            Constants.shared.needUpdateRequest = true
                            let finalDocument = PDFDocumentModel(data: data, document: self.document)
                            
                            presenter.setupFirstShare()
                            presenter.saveDocumentModel(finalDocument) { errorMessage in
                                guard let errorMessage = errorMessage else {
                                    let controller = SuccessSigningViewController()
                                    controller.delegate = self
                                    controller.document = finalDocument
                                    controller.modalPresentationStyle = .overCurrentContext
                                    
                                    self.hideLoading()
                                    self.present(controller, animated: false)
                                    
                                    return
                                }
                                
                                self.hideLoading()
                                self.showAttentionMessage(errorMessage)
                            }
                        }
                
                        return
                    }
                    
                    self.nameLabel.text = ""
                    self.pagesButton.alpha = 0.0
                    self.backButton.alpha = 0.0
                    self.doneButton.alpha = 0.0
                    
                    self.pageView.image = nil
                    self.backPageView.transform = .identity
                    self.removeFormsFromBackPageView()
                    
                    self.showLoading()
                    self.hidePagesView {
                        self.hideToolView {
                            self.nameLabel.text = "singing.screen.preview.header.label.title".localized()
                            self.doneButton.setTitle("signing.screen.done.button.title".localized(), for: .normal)
                            
                            self.pagesButton.alpha = self.document.pages.count > 1 ? 1.0 : 0.0
                            self.backButton.alpha = 1.0
                            self.doneButton.alpha = 1.0
                            
                            self.isPreview = true
                            self.selectedPage = 0
                            self.selectPageAtIndex(0)
                            
                            self.hideLoading()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func pagesButtonAction() {
        guard document.pages.count > 1 else { return }
        pagesButton.tag == 0 ? showPagesView() : hidePagesView()
    }
    
    func showUpgradeConfirmToSaveDraft() {
        let message = "singing.screen.confirm.save.draft.message.text".localized()
        
        let title1 = "singing.screen.confirm.save.draft.upgrade.button.title".localized()
        let title2 = "singing.screen.confirm.save.draft.cancel.button.title".localized()
        let title3 = "singing.screen.confirm.save.draft.discard.button.title".localized()
        
        self.showThreeActionsAlert(nil, message: message, title1: title1, title2: title2, title3: title3, actionType3: .cancel,
                                   comp1: {
            self.openPaywall() },
                                   comp2: {},
                                   comp3: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    func showToolView(completion: EmptyBlock?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.toolViewBootomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func hideToolView(completion: EmptyBlock?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.toolViewBootomConstraint.constant = 130
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func showPagesView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            self.reloadData2()
            self.pagesView.alpha = 1.0
        
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.pagesButton.setImage(UIImage(named: "pages-close-icon"), for: .normal)
                self.pagesViewLeadingConstraint.constant = 5
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.pagesButton.tag = 1
                completion?()
            })
        }
    }
    
    func hidePagesView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.pagesButton.setImage(UIImage(named: "pages-open-icon"), for: .normal)
                self.pagesViewLeadingConstraint.constant = -105
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.pagesView.alpha = 0.0
                self.pagesButton.tag = 0
                completion?()
            })
        }
    }
    
    func showCalendarView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.backCalendarViewBottomConstraint.constant = 0.0
                self.blockView.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    func hideCalendarView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.backCalendarViewBottomConstraint.constant = UIScreen.main.bounds.width + 44
                self.blockView.alpha = 0.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    func showCheckboxView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.checkboxViewBottomConstraint.constant = 10.0
                self.blockView.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    func hideCheckboxView(animated: Bool = true, completion: EmptyBlock? = nil) {
        upgradeView.hideUpgradeView() {
            UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
                self.checkboxViewBottomConstraint.constant = 154
                self.blockView.alpha = 0.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    @IBAction func prevMonthButtonAction() {
        prevMonthButton.viewTouched {
            self.monthPicker -= 1
            self.setupCalendarViewStyle()
            self.calendarView.reloadData()
        }
    }
    
    @IBAction func nextMonthButtonAction() {
        nextMonthButton.viewTouched {
            self.monthPicker += 1
            self.setupCalendarViewStyle()
            self.calendarView.reloadData()
        }
    }
    
    func addSignature() {
        guard let presenter = presenter else { return }
        
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.signature)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() || presenter.isFirstSign() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                guard let model = self.presenter?.loadSignatureModelFor(.signature) else {
                    self.openAddSignature(type: .signature)
                    return
                }
                
                self.showFormWithType(.signature, model: model)
            }
        }
    }
    
    func addInitials() {
        guard let presenter = presenter else { return }
        
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.initials)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() || presenter.isFirstSign() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                guard let model = self.presenter?.loadSignatureModelFor(.initials) else {
                    self.openAddSignature(type: .initials)
                    return
                }
                
                self.showFormWithType(.initials, model: model)
            }
        }
    }
    
    func freestyle() {
        guard let presenter = presenter else { return }
        
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.freestyle)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                guard let model = self.presenter?.loadSignatureModelFor(.freestyle) else {
                    self.openAddSignature(type: .freestyle)
                    return
                }
                
                self.showFormWithType(.freestyle, model: model)
            }
        }
    }
    
    func addText() {
        guard let presenter = presenter else { return }
        
        presenter.defaultPaintbrushSettings()
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.text)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() || presenter.isFirstSign() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                self.showFormWithType(.text)
            }
        }
    }
    
    func addCheckbox() {
        guard let presenter = presenter else { return }
        
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.checkbox)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() || presenter.isFirstSign() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                self.showFormWithType(.checkbox)
            }
        }
    }
    
    func addDate() {
        guard let presenter = presenter else { return }
        
        presenter.defaultPaintbrushSettings()
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView(.date)
            self.upgradeView.hideUpgradeView() {
                guard presenter.isPremium() || presenter.isFirstSign() else {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                self.showFormWithType(.date)
            }
        }
    }
    
    func showFormWithType(form: SignatureForm? = nil, _ type: SigningToolbarModel, model: SignatureModel? = nil) {
        hidePagesView() {
            guard let form = form else {
                let form = SignatureForm()
                form.delegate = self
                form.helper = self
                form.pageIndex = self.selectedPage
                form.viewToMagnify = self.pageView
                form.showForm(in: self.backPageView, withType: type, andModel: model)
                return
            }
        
            form.configureForm(model: model)
        }
    }
    
    func copyFormInCurrentPage(_ copyForm: SignatureForm) {
        hidePagesView() {
            let form = SignatureForm()
            form.delegate = self
            form.helper = self
            form.pageIndex = self.selectedPage
            form.viewToMagnify = self.pageView
            form.signDate = copyForm.signDate
            form.checkbox = copyForm.checkbox
            form.signText = copyForm.signText
            form.signViewWidth = copyForm.signViewWidth
            form.signViewHeight = copyForm.signViewHeight
            form.showForm(in: self.backPageView, withType: copyForm.type, andModel: copyForm.model)
        }
    }
    
    func copyFormInAllPages(_ copyForm: SignatureForm) {
        hidePagesView() {
            for index in 0 ..< self.document.pages.count {
                guard index != self.selectedPage else { continue }
                
                let form = SignatureForm()
                form.delegate = self
                form.helper = self
                form.pageIndex = index
                form.pointX = copyForm.pointX
                form.pointY = copyForm.pointY
                form.signDate = copyForm.signDate
                form.checkbox = copyForm.checkbox
                form.signText = copyForm.signText
                form.signViewWidth = copyForm.signViewWidth
                form.signViewHeight = copyForm.signViewHeight
                form.viewToMagnify = self.pageView
                form.showForm(in: self.backPageView, withType: copyForm.type, andModel: copyForm.model)
            }
        }
    }
    
    func selectPageAtIndex(_ index: Int) {
        guard let presenter = presenter else { return }
        guard index < document.pages.count else { return }
        
        upgradeView.hideUpgradeView() {
            self.prepareUpgradeView()
            self.upgradeView.hideUpgradeView() {
                if index > 0 && !presenter.isPremium() {
                    self.upgradeView.showUpgradeView(at: 125)
                    return
                }
                
                let image = self.document.pages[index]
                
                self.removeFormsFromBackPageView()
                self.updateBackPageViewBounds(image: image)
                self.pageView.image = image
                self.selectedPage = index
            
                guard let forms = self.document.forms[index] else { return }
                
                for form in forms {
                    guard !self.isPreview else {
                        form.prepareForPublish()
                        self.backPageView.addSubview(form)
                        continue
                    }
                    
                    form.delegate = self
                    form.helper = self
                    
                    form.lostFocus()
                    form.isUserInteractionEnabled = true
                    
                    self.backPageView.addSubview(form.magnifyView)
                    self.backPageView.addSubview(form)
                }
            }
        }
    }
    
    func publishDocument(completion: @escaping (Data?) -> Void) {
        guard document.pages.count > 0 else {
            completion(nil)
            return
        }
        
        document.publishPages.removeAll()
        
        for index in 0 ..< document.pages.count {
            guard let forms = document.forms[index], forms.count > 0 else {
                document.publishPages.append(document.pages[index])
                continue
            }
            
            removeFormsFromPageView()
            pageView.image = document.pages[index]
            
            for form in forms {
                form.prepareForPublish()
                pageView.addSubview(form)
            }
                    
            document.publishPages.append(pageView.asImage())
        }
        
        PDFManager.shared.createPDF(from: document.publishPages, withName: document.filename) { pdfURL, data, errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self.showAttentionMessage(errorMessage)
                }
                
                completion(data)
            }
        }
    }
    
    func shareAfterSuccessSigning(_ document: PDFDocumentModel) {
        guard let navigationController = self.navigationController else { return }
        
        navigationController.popToRootViewController(animated: true) {
            guard let mainController = navigationController.viewControllers.first as? MainViewController else { return }
            mainController.shareDocument(document)
        }
    }
}

extension SigningViewController: SigningViewInput {
    
    func setupInitialState(document: DocumentModel) {
        self.document = document
        
        nameLabel.text = "" //"singing.screen.header.label.title".localized()
        nameLabel.textColor = .appDarkTextColor
        nameLabel.font = .appHeadline2
        
        doneButton.setTitle("signing.screen.finish.button.title".localized(), for: .normal)
        doneButton.setTitleColor(.appSystemColor, for: .normal)
        doneButton.titleLabel?.font = .appHeadline3
        
        pagesButton.tag = 0
        pagesButton.tintColor = .appSystemColor
        pagesButton.setTitle("", for: .normal)
        pagesButton.setTitleColor(.appSystemColor, for: .normal)
        pagesButton.setImage(UIImage(named: "pages-open-icon"), for: .normal)
        pagesButton.titleLabel?.font = .appHeadline3
        pagesButton.alpha = document.pages.count > 1 ? 1.0 : 0.0
        
        pagesViewLeadingConstraint.constant = -105
        pagesView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        pagesView.isUserInteractionEnabled = true
        pagesView.layer.cornerRadius = 6
        pagesView.alpha = 0.0
        
        blockView.alpha = 0.0
        blockView.isUserInteractionEnabled = true
        
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .left
        swipe.addTarget(self, action: #selector(swipeHandler2))
        pagesView.addGestureRecognizer(swipe)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapBackViewHandler))
        backPageView.isUserInteractionEnabled = true
        backPageView.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer()
        pinch.delegate = self
        pinch.addTarget(self, action: #selector(pinchBackViewHandler))
        backPageView.addGestureRecognizer(pinch)
        
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(panBackViewHandler))
        backPageView.addGestureRecognizer(pan)
        
        toolView.backgroundColor = .appSystemColor10
        selectPageAtIndex(selectedPage)
        
        setupCollectionView()
        setupCollectionView2()
        
        setupCheckboxView()
        setupCalendarView()
        setupToolbarInitialState()
    }
    
    func updateBackPageViewBounds(image: UIImage) {
        let ratio = image.size.width / image.size.height
        
        if ratio > 1 {
            backPageViewWidthConstraint.constant = UIScreen.main.bounds.width
            backPageViewHeightConstraint.constant = backPageViewWidthConstraint.constant / ratio
        } else if ratio < 1 {
            backPageViewHeightConstraint.constant = UIScreen.main.bounds.height - 240
            backPageViewWidthConstraint.constant = backPageViewHeightConstraint.constant * ratio
            
            while backPageViewWidthConstraint.constant > UIScreen.main.bounds.width {
                backPageViewHeightConstraint.constant -= 5
                backPageViewWidthConstraint.constant = backPageViewHeightConstraint.constant * ratio
            }
        } else {
            backPageViewWidthConstraint.constant = UIScreen.main.bounds.width
            backPageViewHeightConstraint.constant = UIScreen.main.bounds.width
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func reloadData2() {
        collectionView2.reloadData()
    }
    
    func reloadData3() {
        collectionView3.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SigningToolbarCell.self)
    }
    
    func setupCollectionView2() {
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.register(SelectPageCell.self)
    }
    
    func setupCollectionView3() {
        collectionView3.register(SelectPageCell.self)
    }
    
    func setupCheckboxView() {
        checkboxView.setCornerRadius(radius: 12)
        checkboxView.isUserInteractionEnabled = true
        checkboxViewBottomConstraint.constant = 154
        checkboxView.dropShadow(color: .appDarkTextColor60, opacity: 0.5, offSet: CGSize(width: 0.3, height: 0.3), radius: 12, scale: false)
        
        collectionView3LeadingConstraint.constant = (UIScreen.main.bounds.width - 80 * 3 - 48) / 2
        
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .down
        swipe.addTarget(self, action: #selector(swipeHandler3))
        checkboxView.addGestureRecognizer(swipe)
    }
    
    func setupCalendarView() {
        backCalendarView.setCornerRadius(radius: 12)
        backCalendarView.isUserInteractionEnabled = true
        backCalendarView.dropShadow(color: .appDarkTextColor60, opacity: 0.5, offSet: CGSize(width: 0.3, height: 0.3), radius: 12, scale: false)
        backCalendarViewBottomConstraint.constant = UIScreen.main.bounds.width + 44
        
        editDateStyleButton.tintColor = .appSystemColor
        
        let today = Date()
        calendarView.setDisplayDate(today)
        calendarView.selectDate(today)
        calendarView.marksWeekends = false
        calendarView.dataSource = self
        
        calendarView.multipleSelectionEnable = false
        calendarView.tintAdjustmentMode = .normal
        calendarView.direction = .vertical
        
        setupCalendarViewStyle()
        calendarView.reloadData()
        
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .down
        swipe.addTarget(self, action: #selector(swipeHandler))
        backCalendarView.addGestureRecognizer(swipe)
    }
    
    func setupCalendarViewStyle() {
        let style = CalendarView.Style()
        style.firstWeekday = .monday
        style.cellShape = .round
        style.cellFont = .appHeadline3
        
        style.cellColorToday = .white
        style.cellTextColorToday = .appDarkTextColor
        
        style.cellColorAdjacent = .appDarkTextColor
        style.cellColorOutOfRange = .appDarkTextColor
        style.cellTextColorDefault = .appDarkTextColor
        style.cellColorDefault = .white
         
        style.cellSelectedBorderWidth = 0.0
        style.cellSelectedColor = monthPicker == 0 ? .appSystemColor : style.cellColorDefault
        style.cellSelectedTextColor = monthPicker == 0 ? .white : style.cellTextColorDefault
        
        style.headerTopMargin = 12.0
        style.headerFont = .appHeadline2
        style.headerTextColor = .appDarkTextColor
        
        style.weekdaysFont = .appHintText
        style.weekDayTransform = .uppercase
        style.weekdaysTextColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.3)
        
        style.showAdjacentDays = false
        calendarView.style = style
    }
    
    @objc func tapBackViewHandler() {
        hidePagesView()
        hideCheckboxView()
        hideCalendarView()
        
        guard !isPreview else { return }
        guard let forms = document.forms[selectedPage] else { return }
        for form in forms { form.lostFocus() }
        nameLabel.text = ""
    }
    
    @objc func swipeHandler() {
        hideCalendarView()
    }
    
    @objc func swipeHandler2() {
        hidePagesView()
    }
    
    @objc func swipeHandler3() {
        hideCheckboxView()
    }
    
    @objc func pinchBackViewHandler(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        guard !formMovingActive else { return }
        guard let view = gestureRecognizer.view else { return }
        
        if gestureRecognizer.state == .ended {
            view.transform = .identity
            return
        }
        
        if gestureRecognizer.state == .began { tapBackViewHandler() }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            view.transform = transform
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc func panBackViewHandler(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        guard !formMovingActive else { return }
        guard let view = gestureRecognizer.view else { return }
        
        if gestureRecognizer.state == .ended {
            view.transform = .identity
            return
        }
        
        if gestureRecognizer.state == .began { tapBackViewHandler() }
        
        let translation = gestureRecognizer.translation(in: view)
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let transform = view.transform.translatedBy(x: translation.x, y: translation.y)
            view.transform = transform
            gestureRecognizer.setTranslation(CGPoint.zero, in: view)
        }
    }
    
    func prepareUpgradeView(_ model: SigningToolbarModel? = nil) {
        upgradeView = UpgradeView()
        upgradeView.delegate = self
        upgradeView.actionMessage = "upgrade.view.action.title".localized()
        
        guard let model = model else {
            upgradeView.upgradeMessage = "upgrade.view.multipaging.message.text".localized()
            upgradeView.configure()
            return
        }
        
        upgradeView.upgradeMessage = model.upgradeMessage
        upgradeView.configure()
    }
    
    func removeFormsFromBackPageView() {
        let subviews = backPageView.subviews
        guard subviews.count > 0 else { return }
        
        for index in 0 ..< subviews.count {
            guard let subview = subviews[index] as? SignatureForm else { continue }
            subview.magnifyView.removeFromSuperview()
            subview.removeFromSuperview()
        }
    }
    
    func removeFormsFromPageView() {
        let subviews = pageView.subviews
        guard subviews.count > 0 else { return }
        
        for index in 0 ..< subviews.count {
            guard let subview = subviews[index] as? SignatureForm else { continue }
            subview.removeFromSuperview()
        }
    }
    
    func askForCopyForm(comp1: @escaping EmptyBlock, comp2: @escaping EmptyBlock) {
        guard let presenter = presenter else { return }
        guard document.pages.count > 0 else { return }
        
        hidePagesView() {
            if self.document.pages.count == 1 { comp1(); return }
            if self.document.pages.count > 0 && !presenter.isPremium() { comp1(); return }
        
            let header = "preview.screen.crop.menu.header.title".localized()
            let message = "signature.form.copy.form.message.text".localized()
            
            let title1 = "signature.form.copy.form.this.page.title".localized()
            let title2 = "signature.form.copy.form.all.pages.title".localized()
            let title3 = "common.cancel.button.alert".localized()
            
            self.showThreeActionsAlert(header, message: message, title1: title1, title2: title2, title3: title3, actionType3: .cancel,
                                       comp1: comp1, comp2: comp2, comp3: {})
        }
    }
    
    func prepareFormsBeforeMovingForm(_ movingForm: SignatureForm) {
        guard let forms = document.forms[selectedPage] else { return }
        
        for form in forms {
            if form.formId == movingForm.formId { continue }
            
            form.removeFromSuperview()
            pageView.addSubview(form)
            
            form.hideFormBeforeMoving()
        }
    }
    
    func prepareFormsAfterMovingForm(_ movingForm: SignatureForm) {
        guard let forms = document.forms[selectedPage] else { return }
        
        for form in forms {
            if form.formId == movingForm.formId { continue }
            
            form.removeFromSuperview()
            backPageView.addSubview(form)
            
            form.showFormAfterMoving()
        }
    }
    
    func setFocusOnForm(_ focusForm: SignatureForm) {
        guard let forms = document.forms[selectedPage] else { return }
        for form in forms { form.lostFocus() }
        focusForm.getFocus()
    }
    
    func checkPointForSignatureForms(_ point: CGPoint) -> Bool {
        guard let forms = document.forms[selectedPage] else { return false }
        return forms.filter({ $0.frame.contains(point) && $0.hasFocus }).count > 0
    }
    
    func setNameLabelWhenFormGetFocus(_ form: SignatureForm) {
        nameLabel.text = form.type.title
    }
    
    func setNameLabelWhenFormLostFocus() {
        nameLabel.text = ""
    }
}

extension SigningViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView { return 1 }
        return document.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView { return dataSource.count }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            let cell: SigningToolbarCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let model = dataSource[indexPath.item]
            
            if let selectedMenu = selectedMenu, selectedMenu == model {
                cell.configure(model: model, selected: true)
            } else {
                cell.configure(model: model, selected: false)
            }
            
            return cell
        } else if collectionView == self.collectionView2 {
            let cell: SelectPageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            
            let index = indexPath.section
            cell.configure2(index: index, page: document.pages[index], current: index == selectedPage)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension SigningViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView { return CGSize(width: 80, height: 100) }
        return CGSize(width: 65, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.collectionView {
            let inset = (collectionView.bounds.height - 100) / 2
            return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        }
        
        let inset = (collectionView.bounds.height - 65) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension SigningViewController: SignatureFormProtocol {
    
    func formWasAdded(_ form: SignatureForm, toPage page: Int) {
        document.addForm(form, toPage: page)
        
        guard page == selectedPage else { return }
        setFocusOnForm(form)
        backPageView.addSubview(form.magnifyView)
        backPageView.addSubview(form)
        form.getFocus()
    }
    
    func formWasRemoved(_ form: SignatureForm, fromPage page: Int) {
        
        document.deleteForm(form, fromPage: page)
        
        if form.type == .date { hideCalendarView() }
        if form.type == .checkbox { hideCheckboxView() }
    }

    func formNeedCopyInAllPages(_ form: SignatureForm) {
        if form.type == .date { hideCalendarView() }
        if form.type == .checkbox { hideCheckboxView() }
        
        copyFormInAllPages(form)
        showAttentionMessage("signature.form.was.copied.to.all.pages.success.message.text".localized())
    }
    
    func formNeedCopyInCurrentPage(_ form: SignatureForm) {
        if form.type == .date { hideCalendarView() }
        if form.type == .checkbox { hideCheckboxView() }
        
        copyFormInCurrentPage(form)
    }
    
    func formNeedEdit(_ form: SignatureForm, with type: SigningToolbarModel) {
        switch type {
        case .signature, .initials, .freestyle:
            guard let type = DrawTypeModel.drawTypeFor(type.rawValue) else { return }
            guard let model = self.presenter?.loadSignatureModelFor(type) else { return }
            
            openAddSignature(form, type: type, model: model)
        case .text:
            form.prepareBeforeEditTextField()
        case .checkbox:
            collectionView3.delegate = form
            collectionView3.dataSource = form
            collectionView3.register(SelectCheckboxCell.self)
            reloadData3()
            showCheckboxView()
        case .date:
            selectedDate = form.signDate
            calendarView.delegate = form
            calendarView.setDisplayDate(selectedDate)
            calendarView.reloadData()
            
            showCalendarView()
        }
    }
}

extension SigningViewController: CalendarViewDataSource {
    
    func startDate() -> Date {
        guard let date = self.calendarView.calendar.date(byAdding: .month, value: monthPicker, to: selectedDate) else { return Date() }
        return date
    }
    
    func endDate() -> Date {
        guard let date = self.calendarView.calendar.date(byAdding: .month, value: monthPicker, to: selectedDate) else { return Date() }
        return date
    }
    
    func headerString(_ date: Date) -> String? {
        return nil
    }
}

extension SigningViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return false }
        let point = gestureRecognizer.location(in: view)
        return !checkPointForSignatureForms(point)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




