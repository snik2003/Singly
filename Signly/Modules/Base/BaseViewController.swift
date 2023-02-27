//
//  BaseViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit
import PDFKit

class BaseViewController: UIViewController {
    
    var openTransition: CATransition {
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        return transition
    }
    
    var closeTransition: CATransition {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        return transition
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        guard self is LaunchViewController else { return .darkContent }
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .appBackgroundColor
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleImportedDoucment()
        OrientationManager.checkViewControllerForAppearance(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationManager.checkViewControllerForDisappearance(self)
    }
    
    func setupRootViewController(isOnboard: Bool) {
        if isOnboard {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.setupRootViewController()
        } else if let navigationController = self.navigationController, navigationController.viewControllers.count == 1 {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.setupRootViewController()
        } else {
            closeViewControllerAction()
        }
    }
    
    func closeViewControllerAction(animated: Bool = true) {
        self.navigationController?.view.layer.add(closeTransition, forKey: nil)
        self.navigationController?.popViewController(animated: animated)
    }
    
    func dismissPresentedViewController(animated: Bool, completion: @escaping EmptyBlock) {
        guard let controller = BaseViewController.topPresentedController as? UIAlertController else { completion(); return }
        controller.dismiss(animated: true, completion: completion)
    }
    
    func openAddSignature(_ form: SignatureForm? = nil, type: DrawTypeModel, model: SignatureModel? = nil) {
        let controller = AddSignatureModuleConfigurator.instantiateModule(type: type, model: model)

        controller.form = form
        if let delegate = self as? SigningViewController { controller.delegate = delegate }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func handleImportedDoucment() {
        if self is LaunchViewController { return }
        if self is OnboardViewController { return }
        if self is PaywallViewController { return }
        
        guard let file = Constants.shared.importedDocumentURL else { return }
        
        do {
            var pages: [UIImage] = []
            let data = try Data.init(contentsOf: file.absoluteURL)
            
            let fileExtension = file.pathExtension
            let filename = file.lastPathComponent.replacingOccurrences(of: "." + fileExtension, with: "")
            
            var fileType: DocumentType = DocumentType.typeFromExtension(fileExtension)
            
            if fileExtension == "pdf" {
                fileType = .pdf
                
                guard let pdfFile = PDFDocument(url: file), pdfFile.pageCount > 0 else { return }
                for index in 0 ..< pdfFile.pageCount {
                    let pdfPage = pdfFile.page(at: index)
                    let dpi: CGFloat = 5.0
                    let rect = CGSize(width: UIScreen.main.bounds.width * dpi, height: UIScreen.main.bounds.height * dpi)
                    guard let image = pdfPage?.thumbnail(of: rect, for: .mediaBox) else { continue }
                    pages.append(image)
                }
            } else {
                guard let image = UIImage(data: data) else { return }
                pages.append(image)
            }
            
            guard pages.count > 0 else {
                Constants.shared.importedDocumentURL = nil
                showAttentionMessage("import.document.screen.import.document.error.message".localized())
                return
            }
            
            Constants.shared.importedDocumentURL = nil
            
            let document = DocumentModel(filename: filename, type: fileType, data: data, pages: pages)
            let controller = PreviewModuleConfigurator.instantiateModule(document: document)
            self.navigationController?.pushViewController(controller, animated: true)
            
        } catch let error {
            Constants.shared.importedDocumentURL = nil
            showAttentionMessage(error.localizedDescription)
        }
    }
}

extension BaseViewController {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
    
    static var topPresentedController: UIViewController? {
        get {
            var presentingController = UIApplication.shared.keyWindow?.rootViewController
            while let presentedController = presentingController?.presentedViewController, !presentedController.isBeingDismissed {
                presentingController = presentedController
            }
            return presentingController
        }
    }
}

extension UINavigationController {
    
    func popViewController(animated: Bool, completion: EmptyBlock?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        popViewController(animated: animated)
        
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool, completion: EmptyBlock?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        popToRootViewController(animated: animated)
        
        CATransaction.commit()
    }
}

extension BaseViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController!
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        hideLoading()
    }
}
