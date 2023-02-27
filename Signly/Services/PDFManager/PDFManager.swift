//
//  PDFManager.swift
//  Signly
//
//  Created by Сергей Никитин on 10.09.2022.
//

import UIKit
import PDFKit

final class PDFManager {
    static let shared = PDFManager()
    
    var images: [UIImage] = []
    
    func createPDF(from images: [UIImage], withName name: String?, completion: @escaping (URL?, Data?, String?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            guard images.count > 0 else {
                completion(nil,nil,"The number of pages must be greater than zero")
                return
            }
            
            let name = name ?? UUID().uuidString
            let stringURL = NSTemporaryDirectory() + "/" + name + ".pdf"
            let url = URL(fileURLWithPath: stringURL)
            
            guard self.removeFileAtURLIfExists(path: stringURL) else {
                completion(nil,nil,"Unable to delete file:\n\(stringURL)")
                return
            }
            
            let document = PDFDocument()
            for index in 0 ..< images.count {
                let image = images[index]
                guard let page = PDFPage(image: image) else { continue }
                document.insert(page, at: index)
            }

            guard let data = document.dataRepresentation() else {
                completion(nil,nil,"Could not create PDF file: unknown error")
                return
            }
            
            do {
                try data.write(to: url)
                completion(url,data,nil)
            } catch let error {
                completion(nil,nil,"Could not create PDF file: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func openPDF(withData data: Data, andName name: String, in controller: BaseViewController) {
        let stringURL = NSTemporaryDirectory() + "/" + name + ".pdf"
        let url = URL(fileURLWithPath: stringURL)
        
        guard removeFileAtURLIfExists(path: stringURL) else {
            controller.showAttentionMessage("Unable to delete file:\n\(stringURL)")
            return
        }
        
        do {
            try data.write(to: url)
            openPDF(withURL: url, andName: name, in: controller)
        } catch let error {
            controller.showAttentionMessage("Could not create PDF file: \(error.localizedDescription)")
        }
    }
    
    func openPDF(withURL url: URL, andName name: String, in controller: BaseViewController) {
        let pdfController = PDFViewController(pdfURL: url, name: name)
        
        guard #available(iOS 13.0, *) else {
            pdfController.modalPresentationStyle = .overFullScreen
            controller.present(pdfController, animated: true)
            return
        }
        
        pdfController.isModalInPresentation = true
        controller.present(pdfController, animated: true)
    }
    
    private func removeFileAtURLIfExists(path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        
        return true
    }
}
