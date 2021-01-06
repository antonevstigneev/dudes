//
//  FilterCell.swift
//  Dudes Stickers
//
//  Created by Anton Evstigneev on 05.01.2021.
//

import Foundation
import UIKit

class FilterCell: UICollectionViewCell {
    let label = UILabel()
    static let reuseIdentifier = "filter-cell-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? UIColor.systemGreen : UIColor.darkGray
        }
    }
}

extension FilterCell {
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.font = UIFont(name: "Menlo", size: 13.0)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center

        contentView.addSubview(label)
        
        let inset = CGFloat(12)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            ])
    }
}
