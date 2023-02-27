//
//  FilterViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

protocol FilterViewInput: BaseViewInput {
    func setupInitialState(page: UIImage)
}

final class FilterViewController: BaseViewController {

    weak var delegate: PreviewViewController?
    
    var presenter: FilterViewOutput?
    
    var page: UIImage!
    var filter = FilterModel.original
    var dataSource: [FilterModel] = FilterModel.allCases.filter({ $0.isActive == true })
    
    var paramsViewShown = false
    var contrast: Float = 25
    var brightness: Float = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var pageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var paramsView: UIView!
    @IBOutlet weak var paramsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var paramValueView: UIView!
    @IBOutlet weak var paramValueLabel: UILabel!
    @IBOutlet weak var paramSlider: UISlider!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
        addRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func closeButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonAction() {
        guard let delegate = self.delegate else { return }
        guard let image = filter.image(page, value: nil) else { return }
        
        doneButton.viewTouched {
            delegate.document.pages[delegate.selectedPage] = image
            delegate.pageView.image = image
            delegate.filter = self.filter
            self.closeButtonAction()
        }
    }
    
    @IBAction func paramSliderValueChanged(sender: UISlider) {
        if filter == .contrast {
            contrast = sender.value
            reloadData()
        } else if filter == .brightness {
            brightness = sender.value
            reloadData()
        }
    }
}

extension FilterViewController: FilterViewInput {
    
    func setupInitialState(page: UIImage) {
        self.page = page
        
        nameLabel.text = "filter.screen.header.label.title".localized()
        nameLabel.textColor = .appDarkTextColor
        nameLabel.font = .appHeadline2
        
        doneButton.setTitle("filter.screen.done.button.title".localized(), for: .normal)
        doneButton.setTitleColor(.appSystemColor, for: .normal)
        doneButton.titleLabel?.font = .appHeadline3
        
        toolView.backgroundColor = .appSystemColor10
        
        paramValueLabel.textColor = .appDarkTextColor60
        paramValueLabel.font = .appHintText
        
        paramSlider.backgroundColor = .clear
        paramSlider.tintColor = .appSystemColor
        paramSlider.thumbTintColor = .appSystemColor
        paramSlider.minimumTrackTintColor = .appSystemColor
        paramSlider.maximumTrackTintColor = .appSystemColor30
        paramSlider.minimumValue = 0
        paramSlider.maximumValue = 50
        paramSlider.value = contrast
        
        paramsView.backgroundColor = .appSystemColor10
        hideParamsView(animated: false)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterPageCell.self)
    }
    
    func reloadData() {
        collectionView.reloadData()
        
        switch filter {
        case .original, .blackWhite, .grayscale, .contrast:
            if paramsViewShown {
                hideParamsView(animated: true)
            }
        case .brightness:
            let value = filter == .contrast ? contrast : brightness
            paramValueLabel.text = numberFormatter.string(from: NSNumber(value: value))
            paramSlider.value = value
            
            if !paramsViewShown {
                showParamsView(animated: true)
            }
        }
    }
    
    func showParams() {
        paramsViewHeightConstraint.constant = 80
        paramValueView.alpha = 1.0
        paramsViewShown = true
    }
    
    func showParamsView(animated: Bool = true, completion: EmptyBlock? = nil) {
        guard animated else {
            showParams()
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.showParams()
        }, completion: { _ in
            completion?()
        })
    }
    
    func hideParams() {
        paramsViewHeightConstraint.constant = 0
        paramValueView.alpha = 0.0
        paramsViewShown = false
    }
    
    func hideParamsView(animated: Bool = true, completion: EmptyBlock? = nil) {
        guard animated else {
            hideParams()
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.hideParams()
        }, completion: { _ in
            completion?()
        })
    }
    
    func addRecognizers() {
        pageView.clipsToBounds = true
        pageView.layer.masksToBounds = true
        pageView.isUserInteractionEnabled = true
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateRecognized(_:)))
        pageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(_:)))
        pageView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:)))
        pageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func panRecognized(_ gestureRecognizer : UIPanGestureRecognizer) {
            
        guard let imageView = gestureRecognizer.view as? UIImageView else { return }
        
        let translation = gestureRecognizer.translation(in: imageView)
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
            imageView.transform = transform
            gestureRecognizer.setTranslation(CGPoint.zero, in: imageView)
        }
    }
    
    @objc func pinchRecognized(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        guard let imageView = gestureRecognizer.view as? UIImageView else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let transform = imageView.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            imageView.transform = transform
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc func rotateRecognized(_ gestureRecognizer : UIRotationGestureRecognizer) {
        
        guard let imageView = gestureRecognizer.view as? UIImageView else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let transform = imageView.transform.rotated(by: gestureRecognizer.rotation)
            imageView.transform = transform
            gestureRecognizer.rotation = 0
        }
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: FilterPageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        cell.image = self.page
        
        let model = dataSource[indexPath.item]
        let selected = model == filter
        let value: Float? = model == .contrast ? contrast : model == .brightness ? brightness : nil
        
        cell.configure(model: model, selected: selected, value: value)
        if selected { collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally) }
        
        return cell
    }
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let inset = (collectionView.bounds.height - 120) / 2
        return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }
}


