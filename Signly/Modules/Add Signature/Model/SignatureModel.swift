//
//  SignatureModel.swift
//  Signly
//
//  Created by Сергей Никитин on 07.09.2022.
//

import UIKit

class SignatureModel {
    var type: DrawTypeModel
    var brush: SignatureBrushModel
    var penColor: SignatureColorModel
    var image: UIImage
    var points: [[CGPoint]]
    var createDate: Date
    
    init(type: DrawTypeModel, image: UIImage, points: [[CGPoint]], penColor: SignatureColorModel, brush: SignatureBrushModel) {
        self.type = type
        self.brush = brush
        self.image = image
        self.points = points
        self.penColor = penColor
        self.createDate = Date()
    }
    
    init(type: DrawTypeModel, image: UIImage, points: [[CGPoint]], penColor: SignatureColorModel, brush: SignatureBrushModel, date: Date) {
        self.type = type
        self.brush = brush
        self.image = image
        self.points = points
        self.penColor = penColor
        self.createDate = date
    }
    
    func convertImageToData(image: UIImage) -> Data? {
        guard let data = image.pngData() else { return nil }
        return data
    }
    
    static func convertDataToImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
    
    func convertPointsToData(points: [[CGPoint]]) -> Data? {
        guard let data = try? JSONEncoder().encode(points) else { return nil }
        return data
    }
    
    static func convertDataToPoints(data: Data?) -> [[CGPoint]]? {
        guard let data = data else { return nil }
        guard let points = try? JSONDecoder().decode([[CGPoint]].self, from: data) else { return nil }
        return points
    }
}
