//
//  PaintbrushModel.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

enum PaintbrushModel: String, CaseIterable {
    case textStyle = "style"
    case textColor = "color"
    case textSize = "size"
    
    var title: String {
        return "singing.screen.paintbrush.\(rawValue).model.title".localized()
    }
    
    var dataSource: [Any] {
        switch self {
        case .textStyle:
            return [PaintbrushStyleModel.underline, PaintbrushStyleModel.italic, PaintbrushStyleModel.bold]
        case .textColor:
            return SignatureColorModel.allCases.filter({ $0.isActive })
        case .textSize:
            var dataSource: [CGFloat] = []
            for index in 10 ... 50 { dataSource.append(CGFloat(index)) }
            return dataSource
        }
    }
}
