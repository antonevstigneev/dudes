//
//  StickerpacksViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 16.12.2020.
//

import UIKit
import CoreData

class StickerpacksViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Data
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    // MARK: - Variables
    var isInEditMode: Bool = false
    var dudesStickerpacks: [[Dude]] = []
    var selectedStickerpack: [Dude] = []
    var selectedStickerpacks: [Stickerpack] = []
    var stickerpacks: [Stickerpack] = []
    var stickerpack: Stickerpack!
    var stickerpackTitle: String = ""
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    var currentSnapshot: NSDiffableDataSourceSnapshot<Int, Int>!
    var collectionView: UICollectionView! = nil
    var selectedCells = Set<IndexPath>()
    
    // MARK: - Outlets
    @IBOutlet weak var emptyStateView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStickerpacksData()
        configureHierarchy()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationItems()
        fetchStickerpacksData()
        configureDataSource()
    }

    override var prefersStatusBarHidden: Bool {
         return true
    }
    
    @objc func showAppViewControler() {
        self.performSegue(withIdentifier: "AboutViewController", sender: (Any).self)
    }
}


extension StickerpacksViewController {
    @objc func fetchStickerpacksData() {
        let request: NSFetchRequest = Stickerpack.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["stickers"]
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sort]
        do {
            stickerpacks = try context.fetch(request)
            dudesStickerpacks = []
            for stickerpack in stickerpacks {
                var dudes: [Dude] = []
                for case let sticker as Sticker in stickerpack.stickers!  {
                    let dude = Dude(emotion: sticker.emotion!,
                                    image: sticker.image!,
                                    id: sticker.id!,
                                    timestamp: sticker.timestamp!)
                    // check if id is unique
                    if !dudes.map({ $0.id }).contains( dude.id ) {
                        dudes.append(dude)
                    }
                }
                dudes = dudes.sorted {$0.timestamp < $1.timestamp}
                dudesStickerpacks.append(dudes)
            }
        } catch {
            print("Fetching failed")
        }
    }
    
    @objc func createStickerpack() {
        self.performSegue(withIdentifier: "DudesViewController", sender: (Any).self)
    }
    
    func deleteStickerpack(from indexPath: IndexPath) {
        let actionTitle = "Stickerpack will be deleted from your device."
        showActionAlert(title: actionTitle, message: "", confirmation: "Delete", success: { [self] () -> Void in
            context.delete(stickerpacks[indexPath.row])
            stickerpacks.remove(at: indexPath.row)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            fetchStickerpacksData()
            applyDataSnapshot(animation: false)
        }) { () -> Void in }
    }
}


extension StickerpacksViewController {
    func getStickerpackPreviewImage(from dudes: [Dude], _ size: CGSize) -> UIImage {
        let previewView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*2, height: size.height*2)))
        
        for (i, dude) in dudes.prefix(4).enumerated() {
            var xPosition = (i > 1) ? size.width : 0
            var yPosition = (i < 1) ? size.height : 0
            if i == 3 {
                xPosition = size.width
                yPosition = size.height
            }
            let image = UIImage(data: dude.image)
            let padding = CGFloat(10)
            let imageView = UIImageView(frame: CGRect(x: xPosition + padding, y: yPosition + padding, width: size.width-padding*2, height: size.height-padding*2))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            previewView.addSubview(imageView)
        }

        UIGraphicsBeginImageContext(previewView.bounds.size)
        previewView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let stickersPreviewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return stickersPreviewImage!
    }
}


extension StickerpacksViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 60, trailing: 10)

        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(0.62)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 10, bottom: 10, trailing: 10)
  
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension StickerpacksViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
    }
    
    @objc func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <StickerpackCell, Int> { [self] (cell, indexPath, identifier) in
            let stickerpack = dudesStickerpacks[identifier]
            let stickerpackTitle = "DUDES " + String(format: "%02d", stickerpacks.count - indexPath.row)
            cell.stickerpackTitle.text = stickerpackTitle
            cell.stickersNumber.text = String(format: "%02d", stickerpack.count) + " stickers"
            cell.stickerpackPreview.image = getStickerpackPreviewImage(from: stickerpack, cell.layer.bounds.size)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        applyDataSnapshot(animation: false)
    }
    
    func applyDataSnapshot(animation: Bool = true) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        currentSnapshot.appendSections([0])
        currentSnapshot.appendItems(Array(0..<stickerpacks.count))
        dataSource.apply(currentSnapshot, animatingDifferences: animation)
        
        if stickerpacks.isEmpty {
            view.bringSubviewToFront(emptyStateView)
            emptyStateView.isHidden = false
        } else {
            emptyStateView.isHidden = true
        }
    }
}



// MARK: - Prepare for segue
extension StickerpacksViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? StickerpackViewController {
            destinationVC.stickerpack = stickerpack
            destinationVC.dudes = selectedStickerpack
        }
        if let destinationVC = segue.destination as? DudesViewController {
            let stickerpack = Stickerpack(context: context)
            stickerpack.id = String.random()
            stickerpack.timestamp = Date()
            destinationVC.stickerpack = stickerpack
        }
    }
}



// MARK: - Show stickerpack
extension StickerpacksViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedStickerpack = dudesStickerpacks[indexPath.row]
        stickerpack = stickerpacks[indexPath.row]
        stickerpackTitle = "DUDES " + String(format: "%02d", stickerpacks.count - indexPath.row)
        self.performSegue(withIdentifier: "StickerpackViewController", sender: (Any).self)
    }
}



// MARK: - Context menu
extension StickerpacksViewController {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            return self.createContextMenu(indexPath: indexPath)
        }
    }
    
    func createContextMenu(indexPath: IndexPath) -> UIMenu {
        
        let selectedStickerpack = dudesStickerpacks[indexPath.row]
        let stickersImages = selectedStickerpack.map { UIImage(data: $0.image)! }
        
        let makeDeleteStickerpackAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "minus.circle"),
            attributes: .destructive) { _ in
                self.deleteStickerpack(from: indexPath)
            }
        
        let makeShareStickerpackAction = UIAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareImages(stickersImages)
            }
        
        return UIMenu(title: "", children: [makeShareStickerpackAction,
                                            makeDeleteStickerpackAction,
                                            ])
    }
}



extension StickerpacksViewController {
    func setupNavigationItems() {
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = UIColor(named: "AccentColor")!
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "DUDES", style: .plain, target: self, action: #selector(showAppViewControler))
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor")!], for: .normal)
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(createStickerpack))
    }
}



// MARK: - Data eraser
extension StickerpacksViewController {
    func deleteAllData() {
        for stickerpack in stickerpacks {
            let stickers = stickerpack.mutableSetValue(forKey: "stickers").allObjects as? [Sticker]
            stickers!.forEach( { sticker in
                context.delete(sticker)
            })
            context.delete(stickerpack)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

