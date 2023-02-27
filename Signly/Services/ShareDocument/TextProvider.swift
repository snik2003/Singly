//
//  TextProvider.swift
//  Signly
//
//  Created by Сергей Никитин on 12.09.2022.
//

import UIKit
import LinkPresentation

class TextProvider: NSObject, UIActivityItemSource {
    
    private var document: PDFDocumentModel
    
    init(_ document: PDFDocumentModel) {
        self.document = document
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = document.filename
        metadata.iconProvider = NSItemProvider(object: document.icon!)
        metadata.imageProvider = NSItemProvider(object: document.icon!)
        metadata.originalURL = URL(fileURLWithPath: document.shareText)
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return document.shareText
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        return document.filename + "\n" + document.shareText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        
        return document.filename
    }
}

