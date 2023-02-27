//
//  DocumentType.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit

enum DocumentType {
    case pdf
    case png
    case jpeg
    case image
    
    static func typeFromExtension(_ fileExtension: String) -> DocumentType {
        switch fileExtension {
        case "pdf":
            return .pdf
        case "png":
            return .png
        case "jpg", "jpeg":
            return .jpeg
        default:
            return .image
        }
    }
    
    var stringType: String {
        switch self {
        case .pdf:
            return "PDF Document"
        case .png:
            return "PNG Image"
        case .jpeg:
            return "JPEG Image"
        case .image:
            return "Image"
        }
    }
}
