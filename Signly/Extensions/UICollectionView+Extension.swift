//
//  UICollectionView+Extension.swift
//  CDL
//
//  Created by Сергей Никитин on 09.08.2022.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    func scrollToLeft(animated: Bool) {
        if numberOfSections > 0 {
            if numberOfItems(inSection: 0) > 0 {
                scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: animated)
            }
        }
    }
}
