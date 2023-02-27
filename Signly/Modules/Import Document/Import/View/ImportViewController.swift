//
//  ImportViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 05.09.2022.
//

import UIKit
import PDFKit
import Photos
import MobileCoreServices
import UniformTypeIdentifiers

protocol ImportViewInput: BaseViewInput {
    func setupInitialState(document: DocumentModel?)
}

final class ImportViewController: BaseViewController {

    var presenter: ImportViewOutput?
    
    var dataSource: [ImportModel] = ImportModel.allCases.filter({ $0.isActive == true })
    var document: DocumentModel?
    
    weak var delegate: PreviewViewController?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }

    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func startScanner() {
        let pickerController = UIImagePickerController()
        
        pickerController.mediaTypes = ["public.image"]
        pickerController.videoQuality = .typeHigh
        pickerController.sourceType = .camera
        pickerController.cameraDevice = .rear
        pickerController.allowsEditing = false
        pickerController.delegate = self
        
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true)
    }
    
    func openPhotos() {
        let pickerController = UIImagePickerController()
        
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
        pickerController.delegate = self
        
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true)
    }
    
    func openFiles() {
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [UTType.image, UTType.pdf, UTType.jpeg, UTType.png]
            let supportedTypesStrings: [String] = supportedTypes.compactMap({ $0.identifier })
            let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypesStrings, in: .import)
            
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            documentPicker.modalPresentationStyle = .fullScreen
            
            self.present(documentPicker, animated: true)
        } else {
            let supportedTypesStrings: [String] = [String(kUTTypePNG),String(kUTTypeImage)]
            let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypesStrings, in: .import)
            
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            
            self.present(documentPicker, animated: true)
        }
    }
    
    func openAnotherAppInstruction() {
        let controller = InstructionModuleConfigurator.instantiateModule()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ImportViewController: ImportViewInput {
    
    func setupInitialState(document: DocumentModel?) {
        self.document = document
        
        titleLabel.text = "import.document.screen.header.label.title".localized()
        titleLabel.textColor = .appDarkTextColor
        titleLabel.font = .appHeadline2
        
        reloadData()
    }
    
    func reloadData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImportModelCell.self)
        tableView.reloadData()
    }
}

extension ImportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ImportModelCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        cell.configure(model: dataSource[indexPath.row])
        return cell
    }
}

extension ImportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            let pages: [UIImage] = [image]
            let fileType: DocumentType = .jpeg
            
            var filename = "JPEG Image " + UUID().uuidString
            if let imageURL = info[.imageURL] as? URL { filename = imageURL.lastPathComponent }
                
            
            guard let data = image.jpegData(compressionQuality: 1.0) else {
                showAttentionMessage("import.document.screen.open.document.error.message".localized())
                picker.dismiss(animated: true)
                return
            }
            
            guard let delegate = self.delegate else {
                let document = DocumentModel(filename: filename, type: fileType, data: data, pages: pages)
                
                let controller = PreviewModuleConfigurator.instantiateModule(document: document)
                controller.needToCrop = true
                
                guard let navigationController = self.navigationController else { return }
                navigationController.popViewController(animated: false)
                navigationController.pushViewController(controller, animated: true)
                
                picker.dismiss(animated: true)
                return
            }
            
            delegate.document.pages.append(contentsOf: pages)
            self.navigationController?.popViewController(animated: true)
            
            picker.dismiss(animated: true)
        } else {
            showAttentionMessage("import.document.screen.open.document.error.message".localized())
            picker.dismiss(animated: true)
        }
    }
}

extension ImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let file = urls.first else { return }
        
        do {
            var pages: [UIImage] = []
            let data = try Data.init(contentsOf: file.absoluteURL)
            
            let fileExtension = file.pathExtension
            let filename = file.lastPathComponent.replacingOccurrences(of: "." + fileExtension, with: "")
            
            var fileType: DocumentType = DocumentType.typeFromExtension(fileExtension)
            
            if fileExtension == "pdf" {
                fileType = .pdf
                
                guard let pdfFile = PDFDocument(url: file), pdfFile.pageCount > 0 else { return }
                for index in 0 ..< pdfFile.pageCount {
                    let pdfPage = pdfFile.page(at: index)
                    let dpi: CGFloat = 5.0
                    let rect = CGSize(width: UIScreen.main.bounds.width * dpi, height: UIScreen.main.bounds.height * dpi)
                    guard let image = pdfPage?.thumbnail(of: rect, for: .mediaBox) else { continue }
                    pages.append(image)
                }
            } else {
                guard let image = UIImage(data: data) else { return }
                pages.append(image)
            }
            
            guard pages.count > 0 else {
                showAttentionMessage("import.document.screen.open.document.error.message".localized())
                return
            }
            
            guard let delegate = self.delegate else {
                let document = DocumentModel(filename: filename, type: fileType, data: data, pages: pages)
                let controller = PreviewModuleConfigurator.instantiateModule(document: document)
                
                guard let navigationController = self.navigationController else { return }
                navigationController.popViewController(animated: false)
                navigationController.pushViewController(controller, animated: true)
                return
            }
            
            delegate.document.pages.append(contentsOf: pages)
            self.navigationController?.popViewController(animated: true)
            
        } catch let error {
            showAttentionMessage(error.localizedDescription)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
