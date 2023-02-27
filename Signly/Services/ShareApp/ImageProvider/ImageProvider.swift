//
//  ImageProvider.swift
//  CDL
//
//  Created by Сергей Никитин on 16.08.2022.
//

import UIKit

class ImageProvider: NSObject, UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "App-Icon")!
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return UIImage(named: "App-Icon")
    }
}
