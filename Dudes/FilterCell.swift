//
//  FilterCell.swift
//  Dudes
//
//  Created by Anton Evstigneev on 15.12.2020.
//

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
            layer.borderColor = isSelected ? UIColor(named: "AccentColor")?.cgColor :
                                             UIColor.darkGray.cgColor
            label.textColor = isSelected ? UIColor(named: "AccentColor") :
                                             UIColor.darkGray
        }
    }

}

extension FilterCell {
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.font = UIFont(name: "Menlo", size: 16.0)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.darkGray.cgColor

        contentView.addSubview(label)
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            ])
    }
}
