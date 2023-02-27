//
//  PDFViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 11.09.2022.
//

import UIKit
import PDFKit

class PDFViewController: BaseViewController {
    
    private let pdfURL: URL
    private let document: PDFDocument!
    private let documentName: String!
    
    private var pdfView = PDFView()
    private var thumbnailView = PDFThumbnailView()
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var pagesView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docPageLabel: UILabel!
    
    @IBOutlet weak var thumbViewHeightConstraint: NSLayoutConstraint!
    
    init(pdfURL: URL, name: String) {
        self.pdfURL = pdfURL
        self.document = PDFDocument(url: pdfURL)
        self.documentName = name
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        
        setupPDFView()
        setupThumbnailView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver (self,
                                                selector: #selector(pageChanged),
                                                name: Notification.Name.PDFViewPageChanged,
                                                object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBounds()
    }
    
    @IBAction func backButtonAction() {
        backButton.viewTouched {
            self.dismiss(animated: true)
        }
    }
    
    private func setupPDFView() {
        pdfView.backgroundColor = .appDarkTextColor60
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.displayMode = .singlePageContinuous
        pdfView.displaysPageBreaks = true
        pdfView.pageBreakMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        pdfView.autoScales = true
        
        pdfView.document = document
    }
    
    private func setupThumbnailView() {
        thumbnailView.pdfView = pdfView
        thumbnailView.layoutMode = .horizontal
        thumbnailView.backgroundColor = .appDarkTextColor60
        thumbnailView.clipsToBounds = true
        thumbnailView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    private func updateBounds() {
        pdfView.frame = CGRect(origin: CGPoint.zero, size: backView.bounds.size)
        backView.addSubview(pdfView)
        
        guard document.pageCount > 1 else { return }
        thumbnailView.frame = CGRect(origin: CGPoint.zero, size: thumbView.bounds.size)
        thumbnailView.thumbnailSize = CGSize(width: 80, height: 100)
        thumbView.addSubview(thumbnailView)
    }
    
    private func setupInitialState() {
        thumbViewHeightConstraint.constant = 120
        
        docNameLabel.text = documentName
        docNameLabel.textColor = .appDarkTextColor
        docNameLabel.font = .appHeadline3
        
        docPageLabel.text = "1 of \(document.pageCount)"
        docPageLabel.textColor = UIColor.black.withAlphaComponent(0.3)
        docPageLabel.font = .appSecondaryBodyText
        
        pagesView.dropShadow(color: .appDarkTextColor60, opacity: 0.5, offSet: CGSize(width: 0.3, height: 0.3), radius: 4, scale: false)
        pagesView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        pagesView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        pagesView.layer.borderWidth = 0.4
        pagesView.layer.cornerRadius = 4
        pagesView.clipsToBounds = true
        
        
        guard document.pageCount == 1 else { return }
        thumbViewHeightConstraint.constant = 0
    }
    
    @objc func pageChanged() {
        guard let currentPage = pdfView.currentPage else { return }
        guard let currentPageRef = currentPage.pageRef else {return}
        docPageLabel.text = "\(currentPageRef.pageNumber) of \(document.pageCount)"
    }
}
