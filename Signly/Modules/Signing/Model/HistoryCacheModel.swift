//
//  HistoryCacheModel.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import Foundation

class HistoryCacheModel: Codable, Equatable {
    static func ==(lhs: HistoryCacheModel, rhs: HistoryCacheModel) -> Bool {
        return lhs.text == rhs.text && lhs.date == rhs.date
    }
    
    var text: String
    var date: Date
    
    init(text: String) {
        self.text = text
        self.date = Date()
    }
    
    static func convertModelToData(_ history: [HistoryCacheModel]) -> Data? {
        guard let data = try? JSONEncoder().encode(history) else { return nil }
        return data
    }
    
    static func convertDataToModel(_ data: Data?) -> [HistoryCacheModel]? {
        guard let data = data else { return nil }
        guard let history = try? JSONDecoder().decode([HistoryCacheModel].self, from: data) else { return nil }
        return history
    }
}
