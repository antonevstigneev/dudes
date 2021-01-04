
import UIKit

class DudeCell: UICollectionViewCell {
    let imageView = UIImageView()
    static let reuseIdentifier = "dude-cell-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderColor = isSelected ? UIColor(named: "AccentColor")?.cgColor : .none
            layer.borderWidth = isSelected ? 1.5 : 0
        }
    }
}

extension DudeCell {
    func configure() {
        self.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .none
        contentView.addSubview(imageView)
        layer.cornerRadius = 10

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            ])
    }
}
