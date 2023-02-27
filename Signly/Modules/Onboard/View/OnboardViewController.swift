//
//  OnboardViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit

protocol OnboardViewInput: BaseViewInput {
    func setupInitialState(onboard: OnboardModel)
}

final class OnboardViewController: BaseViewController {

    var presenter: OnboardViewOutput?
    var onboard: OnboardModel = .onboard1
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var hintImage: UIImageView!
    @IBOutlet weak var hintImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hintImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintLabelTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    @IBAction func backButtonAction() {
        guard onboard != .onboard1 else { return }
        
        backButton.viewTouched {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func nextButtonAction() {
        nextButton.viewTouched {
            switch self.onboard {
            case .onboard1:
                let controller = OnboardModuleConfigurator.instantiateModule(onboard: .onboard2)
                self.navigationController?.pushViewController(controller, animated: false)
            case .onboard2:
                let controller = OnboardModuleConfigurator.instantiateModule(onboard: .onboard3)
                self.navigationController?.pushViewController(controller, animated: false)
            case .onboard3:
                let controller = OnboardModuleConfigurator.instantiateModule(onboard: .onboard4)
                self.navigationController?.pushViewController(controller, animated: false)
            case .onboard4:
                self.presenter?.setupFirstLaunch()
                self.openPaywall(isOnboard: true)
                self.presenter?.pushRequest()
                break
            }
        }
    }
}

extension OnboardViewController: OnboardViewInput {
    
    func setupInitialState(onboard: OnboardModel) {
        self.onboard = onboard
        self.view.backgroundColor = .white
        self.gradientView.gradientBackgroundColor(color1: .appGradientColor1, color2: .appGradientColor2)
        
        pageControl.numberOfPages = onboard.numberOfPages
        pageControl.currentPage = onboard.pageIndex
        pageControl.pageIndicatorTintColor = .appSystemColor30
        pageControl.currentPageIndicatorTintColor = .appSystemColor80
        
        backButton.alpha = onboard == .onboard1 ? 0.0 : 1.0
        nextButton.setTitle("onboard.screen.continue.button.title".localized(), for: .normal)
        
        hintImage.image = onboard.hintImage
        
        if onboard == .onboard3 {
            hintLabelTopConstraint.constant = 0
            
            let maxHeight = hintLabelTopConstraint.constant + 374
            hintImageHeightConstraint.constant = min(onboard.hintImageHeight, maxHeight)
            hintImageWidthConstraint.constant = onboard.hintImageWidth * hintImageHeightConstraint.constant / onboard.hintImageHeight
        } else {
            hintLabelTopConstraint.constant = 30
            
            let maxHeight = hintLabelTopConstraint.constant + 374
            hintImageHeightConstraint.constant = min(onboard.hintImageHeight, maxHeight)
            hintImageWidthConstraint.constant = onboard.hintImageWidth * hintImageHeightConstraint.constant / onboard.hintImageHeight
        }
        
        hintLabel.text = onboard.hintText
        hintLabel.textColor = .appDarkTextColor
        hintLabel.font = .appHeadline2
    }
}
