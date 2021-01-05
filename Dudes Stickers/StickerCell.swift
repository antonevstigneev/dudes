//
//  StickerCell.swift
//  Dudes Stickers
//
//  Created by Anton Evstigneev on 05.01.2021.
//

import Messages
import UIKit

class StickerCell: UICollectionViewCell {
    let stickerView = MSStickerView()
    static let reuseIdentifier = "sticker-cell-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension StickerCell {
    func configure() {
        self.isUserInteractionEnabled = true
        stickerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .none
        contentView.addSubview(stickerView)
        layer.cornerRadius = 10

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            stickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            stickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            stickerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            stickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            ])
    }
}
