//
//  TextFormModel.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

enum TextFormModel: CaseIterable {
    case profile
    case history
    case paintbrush
    
    var rowHeight: CGFloat {
        switch self {
        case .profile:
            return 76
        case .history:
            return 56
        case .paintbrush:
            return 56
        }
    }
    
    func dataSource(_ presenter: BaseViewOutput?) -> [Any] {
        switch self {
        case .profile:
            var dataSource: [SettingsModel] = []
            if let value = presenter?.nameValue(), !value.isEmpty { dataSource.append(SettingsModel.name) }
            if let value = presenter?.emailValue(), !value.isEmpty { dataSource.append(SettingsModel.email) }
            if let value = presenter?.companyValue(), !value.isEmpty { dataSource.append(SettingsModel.company) }
            return dataSource
        case .history:
            return presenter?.historyCache() ?? []
        case .paintbrush:
            return [PaintbrushModel.textStyle, PaintbrushModel.textColor, PaintbrushModel.textSize]
        }
    }
}
