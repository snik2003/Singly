//
//  TextProvider.swift
//  CDL
//
//  Created by Сергей Никитин on 16.08.2022.
//

import UIKit
import LinkPresentation

class TextProvider: NSObject, UIActivityItemSource {
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = Constants.shared.shareTitle
        metadata.originalURL = URL(string: Constants.shared.shareLink)
        metadata.url = metadata.originalURL
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "App-Icon")!)
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return Constants.shared.shareTitle
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        return "\(Constants.shared.shareMessage)\n\(Constants.shared.shareLink)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        
        return Constants.shared.shareTitle
    }
}
