//
//  PaintbrushSettingsModel.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import Foundation
import UIKit

final class PaintbrushSettings {
    
    static let shared = PaintbrushSettings()
    
    func setupInstance(style: [PaintbrushStyleModel], color: SignatureColorModel, size: CGFloat) {
        self.style = style
        self.color = color
        self.size = size
    }
    
    var style: [PaintbrushStyleModel] = [.bold]
    var color: SignatureColorModel = .black
    var size: CGFloat = 13
    
    func convertStyleToData() -> Data? {
        guard let data = try? JSONEncoder().encode(self.style) else { return nil }
        return data
    }
    
    static func convertDataToStyle(_ data: Data?) -> [PaintbrushStyleModel] {
        guard let data = data else { return [] }
        guard let style = try? JSONDecoder().decode([PaintbrushStyleModel].self, from: data) else { return [] }
        return style
    }
    
    func currentFont() -> UIFont {
        if style.contains(.bold) && style.contains(.italic) {
            return UIFont(name: "Poppins Bold Italic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        } else if style.contains(.bold) {
            return UIFont(name: "Poppins Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        } else if style.contains(.italic) {
            return UIFont(name: "Poppins Medium Italic", size: size) ?? UIFont.systemFont(ofSize: size)
        } else {
            return UIFont(name: "Poppins Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
}
