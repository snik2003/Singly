//
//  PDFFormModel.swift
//  Signly
//
//  Created by Сергей Никитин on 10.09.2022.
//

import UIKit

class PDFFormModel: Codable {
    var type: String
    var pageIndex: Int
    var pointX: CGFloat?
    var pointY: CGFloat?
    var signDate: Date
    var checkbox: String
    var signText: String
    var signViewWidth: CGFloat
    var signViewHeight: CGFloat
    
    init(form: SignatureForm) {
        self.type = form.type.rawValue
        self.pageIndex = form.pageIndex
        self.pointX = form.pointX
        self.pointY = form.pointY
        self.signViewWidth = form.signViewWidth
        self.signViewHeight = form.signViewHeight
        
        self.signDate = form.signDate
        self.signText = form.signText
        self.checkbox = form.checkbox.rawValue
    }
}
