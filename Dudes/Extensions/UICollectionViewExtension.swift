//
//  UICollectionViewExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 19.12.2020.
//

import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}
