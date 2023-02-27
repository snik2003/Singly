//
//  PaintbrushStyleModel.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import Foundation
import UIKit

enum PaintbrushStyleModel: String, Codable, CaseIterable {
    case underline = "underline"
    case italic = "italic"
    case bold = "bold"
    
    var icon: UIImage? {
        return UIImage(named: "paintbrush-style-\(rawValue)")
    }
}
