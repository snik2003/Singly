//
//  DocumentModel.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit


class DocumentModel {
    var filename: String
    var type: DocumentType
    var createDate: Date
    var updateDate: Date
    var data: Data
    var pages: [UIImage]
    var publishPages: [UIImage] = []
    var forms: [Int: [SignatureForm]] = [:]
    
    init(filename: String, type: DocumentType, data: Data, pages: [UIImage]) {
        self.filename = filename
        self.pages = pages
        self.type = type
        self.data = data
        
        self.createDate = Date()
        self.updateDate = Date()
        
        for index in 0 ..< pages.count { self.forms[index] = [] }
    }
    
    init(document: PDFDocumentModel, filename: String) {
        self.filename = filename
        self.type = DocumentType.typeFromExtension(document.type)
        self.createDate = document.createDate
        self.updateDate = document.updateDate
        self.data = document.originData
        self.pages = []
        self.publishPages = []
        self.forms = [:]
        
        for index in 0 ..< document.publishPages.count {
            guard let image = PDFDocumentModel.convertDataToImage(data: document.publishPages[index]) else { continue }
            self.pages.append(image)
        }
        
        for index in 0 ..< pages.count { self.forms[index] = [] }
    }
    
    func addForm(_ form: SignatureForm, toPage page: Int) {
        forms[page]?.append(form)
    }
    
    func deleteForm(_ form: SignatureForm, fromPage page: Int) {
        forms[page]?.removeAll(where: { $0.formId == form.formId })
    }
}
