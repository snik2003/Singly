//
//  PDFDocumentModel.swift
//  Signly
//
//  Created by Сергей Никитин on 10.09.2022.
//

import UIKit

class PDFDocumentModel: Codable {
    var documentId: String
    var filename: String
    var type: String
    var createDate: Date
    var updateDate: Date
    var originData: Data
    var finalData: Data
    var pages: [Data] = []
    var publishPages: [Data] = []
    var forms: [PDFFormModel] = []
    
    var icon: UIImage? {
        guard publishPages.count > 0 else { return nil }
        guard let image = PDFDocumentModel.convertDataToImage(data: publishPages[0]) else { return nil }
        return image
    }
    
    var fullFilename: String {
        return filename + ".pdf"
    }
    
    var shareText: String {
        guard publishPages.count > 1 else { return "PDF Document • \(sizeInMegaBytes)" }
        return "PDF Document • \(sizeInMegaBytes) • \(publishPages.count) pages"
    }
    
    private var sizeInMegaBytes: String {
        let size = Int64(finalData.count)
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = size < 1024 ? [.useBytes] : size < (1024 * 1024) / 10 ? [.useKB] : [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: size)
    }
    
    init(data: Data, document: DocumentModel) {
        self.documentId = UUID().uuidString
        self.filename = document.filename
        self.type = document.type.stringType
        self.createDate = document.createDate
        self.updateDate = document.updateDate
        self.originData = document.data
        self.finalData = data
        
        for image in document.pages {
            guard let data = convertImageToData(image: image) else { continue }
            self.pages.append(data)
        }
        
        for image in document.publishPages {
            guard let data = convertImageToData(image: image) else { continue }
            self.publishPages.append(data)
        }
        
        for index in 0 ..< document.pages.count {
            guard let forms = document.forms[index], forms.count > 0 else { continue }
            for form in forms {
                let pdfForm = PDFFormModel(form: form)
                self.forms.append(pdfForm)
            }
        }
    }
    
    init(document: PDFDocumentModel, newFilename: String) {
        self.documentId = UUID().uuidString
        self.filename = newFilename
        self.type = document.type
        self.createDate = Date()
        self.updateDate = Date()
        self.originData = document.originData
        self.finalData = document.finalData
        self.pages = document.pages
        self.publishPages = document.publishPages
        self.forms = document.forms
    }
    
    func convertImageToData(image: UIImage) -> Data? {
        guard let data = image.pngData() else { return nil }
        return data
    }
    
    static func convertDataToImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
    
    func convertModelToData() -> Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return data
    }
    
    static func convertDataToModel(data: Data?) -> PDFDocumentModel? {
        guard let data = data else { return nil }
        guard let model = try? JSONDecoder().decode(PDFDocumentModel.self, from: data) else { return nil }
        return model
    }
    
    func convertPublishDataToImages() -> [UIImage] {
        var images: [UIImage] = []
        
        for data in publishPages {
            guard let image = PDFDocumentModel.convertDataToImage(data: data) else { continue }
            images.append(image)
        }
        
        return images
    }
}
