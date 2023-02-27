//
//  FormPaintbrushCell.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class FormPaintbrushCell: BaseTableCell {

    weak var delegate: SigningViewController?
    
    var type: PaintbrushModel?
    var dataSource: [Any] = []
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
}

extension FormPaintbrushCell {
    
    func configure(model: PaintbrushModel) {
        self.type = model
        
        label.text = model.title
        label.textColor = .appDarkTextColor
        label.font = .appHeadline3
        
        dataSource = model.dataSource
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PaintbrushStyleCell.self)
        collectionView.register(PaintbrushSizeCell.self)
        collectionView.register(SignColorCell.self)
        collectionView.reloadData()
        scrollCollectionView()
    }
    
    func scrollCollectionView() {
        guard let type = type else { return }
        
        if type == .textColor, let dataSource = dataSource as? [SignatureColorModel] {
            guard let index = dataSource.firstIndex(of: PaintbrushSettings.shared.color) else { return }
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
        if type == .textSize, let dataSource = dataSource as? [CGFloat] {
            guard let index = dataSource.firstIndex(of: PaintbrushSettings.shared.size) else { return }
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
    }
}

extension FormPaintbrushCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = type else { return UICollectionViewCell() }
        
        if type == .textStyle, let model = dataSource[indexPath.item] as? PaintbrushStyleModel {
            let cell: PaintbrushStyleCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model)
            return cell
        }
        
        if type == .textColor, let model = dataSource[indexPath.item] as? SignatureColorModel {
            let cell: SignColorCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate2 = self
            let selected = PaintbrushSettings.shared.color == model
            cell.configure(model: model, selected: selected)
            return cell
        }
        
        if type == .textSize, let value = dataSource[indexPath.item] as? CGFloat {
            let cell: PaintbrushSizeCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(value: value)
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension FormPaintbrushCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if type == .textSize  { return CGSize(width: 52, height: 64)}
        if type == .textColor { return CGSize(width: 36, height: 64) }
        return CGSize(width: 56, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if type == .textSize,  section == 0 { return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0) }
        if type == .textColor, section == 0 { return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) }
        return UIEdgeInsets.zero
    }
}

