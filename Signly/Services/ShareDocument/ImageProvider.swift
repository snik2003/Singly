//
//  ImageProvider.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit

class ImageProvider: NSObject, UIActivityItemSource {
    
    private var document: PDFDocumentModel
    
    init(_ document: PDFDocumentModel) {
        self.document = document
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return document.icon!
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return document.icon
    }
}

