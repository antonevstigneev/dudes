//
//  StickerpackCell.swift
//  Dudes
//
//  Created by Anton Evstigneev on 18.12.2020.
//


import UIKit

class StickerpackCell: UICollectionViewCell {
    
    let stickerpackPreview = UIImageView()
    let stickerpackTitle = UILabel()
    let stickersNumber = UILabel()
    static let reuseIdentifier = "stickerpack-cell-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension StickerpackCell {
    func configure() {
        self.isUserInteractionEnabled = true
        stickerpackPreview.translatesAutoresizingMaskIntoConstraints = false
        stickerpackTitle.translatesAutoresizingMaskIntoConstraints = false
        stickersNumber.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .none
        contentView.addSubview(stickerpackPreview)
        contentView.addSubview(stickerpackTitle)
        contentView.addSubview(stickersNumber)
        
        layer.cornerRadius = 17
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.0
        stickerpackTitle.font = UIFont(name: "Menlo", size: 16)
        stickersNumber.font = UIFont(name: "Menlo", size: 12)
        stickerpackTitle.textColor = .white
        stickersNumber.textColor = .darkGray

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            stickerpackPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            stickerpackPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            stickerpackPreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            stickerpackPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            
            stickerpackTitle.topAnchor.constraint(equalTo: stickerpackPreview.bottomAnchor, constant: inset * 2),
            stickerpackTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset * 1.5),
            
            stickersNumber.topAnchor.constraint(equalTo: stickerpackTitle.bottomAnchor, constant: inset / 2.5),
            stickersNumber.leadingAnchor.constraint(equalTo: stickerpackTitle.leadingAnchor),
        ])
    }
}
