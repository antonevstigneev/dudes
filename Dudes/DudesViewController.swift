//
//  DudesViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 01.11.2020.
//

import UIKit

class DudesViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Data
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    enum Section {
        case dudes
    }
    let queue = DispatchQueue(label: "Generation Queue")
    var generationTask: DispatchWorkItem?
    var stickerpack: Stickerpack! = nil
    var selectedFilter: Filter = .original
    let dudesGenerator = DudesGenerator()
    var dudes: [Dude] = []
    var dudesBeforeUpdate: [Dude] = []
    var selectedDudes = Set<Dude>()
    var selectedDudesLimit: Int = 99
    var selectedCells = Set<IndexPath>()
    var isGenerating: Bool!
    var dudesCollectionView: UICollectionView!
    var dudesDataSource: UICollectionViewDiffableDataSource<Section, Dude>!
    var dudesSnapshot: NSDiffableDataSourceSnapshot<Section, Dude>!
    var filtersCollectionView: UICollectionView!
    var filtersDataSource: UICollectionViewDiffableDataSource<Int, Int>!
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var selectedLabel: UILabel!
    
    @IBOutlet weak var createStickerpackButton: UIButton!
    @IBAction func createStickerpack(_ sender: Any) {
        isGenerating = false
        generationTask?.cancel()
        queue.suspend()
        self.performSegue(withIdentifier: "StickerpackViewController", sender: (Any).self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        generateDudes()
        let selectedDudesCount = String(format: "%02d", selectedDudes.count)
        selectedLabel.text = "\(selectedDudesCount)/\(selectedDudesLimit) SELECTED"
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(exitGeneration))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firstIndex = IndexPath(row: 0, section: 0)
        self.filtersCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: [])
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.hidesBarsOnSwipe = true
        if generationTask?.isCancelled == true {
            queue.resume()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func exitGeneration() {
        generationTask?.cancel()
        queue.suspend()
        if ((stickerpack.stickers?.count) == 0) {
            context.delete(stickerpack)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is StickerpacksViewController || controller is StickerpackViewController {
                    navController.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
}



// MARK: - Dudes generation method
extension DudesViewController {
    func generateDudes() {
        isGenerating = true
        for _ in 0..<33 {
        generationTask = DispatchWorkItem { [self] in
            queue.async {
                    let dude = dudesGenerator.generate()
                    dudes.append(dude)
                    applyDataSnapshot()
                }
            }
            generationTask?.perform()
        }
        isGenerating = false
    }
    
    private func applyDataSnapshot() {
        DispatchQueue.main.async() { [self] in
            dudesSnapshot = NSDiffableDataSourceSnapshot<Section, Dude>()
            dudesSnapshot.appendSections([.dudes])
            dudesSnapshot.appendItems(dudes)
            dudesDataSource.apply(dudesSnapshot, animatingDifferences: true)
        }
    }
}



// MARK: - Prepare for segue
extension DudesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? StickerpackViewController {
            if stickerpack.isInUpdateMode == true {
                destinationVC.newDudes = Array(selectedDudes)
                destinationVC.dudes = dudesBeforeUpdate + selectedDudes
                destinationVC.stickerpack = self.stickerpack
                destinationVC.stickerpack.id = self.stickerpack.id
                destinationVC.stickerpack.isInUpdateMode = true
            } else {
                destinationVC.dudes = Array(selectedDudes)
                destinationVC.stickerpack = stickerpack
            }
        }
    }
}



// MARK: - CollectionView layout
extension DudesViewController {
    func createDudesLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120),
                                             heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)
  
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}



// MARK: - CollectionView dataSource
extension DudesViewController {
    func configureHierarchy() {
        dudesCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - controlsView.bounds.height), collectionViewLayout: createDudesLayout())
        dudesCollectionView.delegate = self
        dudesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dudesCollectionView.backgroundColor = .black
        dudesCollectionView.allowsMultipleSelection = true
        dudesCollectionView.showsVerticalScrollIndicator = false
        view.addSubview(dudesCollectionView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let frame = CGRect(x: 0, y: 0, width: controlsView.bounds.width, height: 62)
        filtersCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        filtersCollectionView.delegate = self
        filtersCollectionView.contentInset = UIEdgeInsets(top: 12, left: 25, bottom: 0, right: 25)
        filtersCollectionView.showsHorizontalScrollIndicator = false
        controlsView.addSubview(filtersCollectionView)
        view.bringSubviewToFront(controlsView)
    }
    
    func configureDataSource() {
        let dudeCellRegistration = UICollectionView.CellRegistration
        <DudeCell, Dude> { [self] (cell, indexPath, dude) in
            cell.imageView.image = UIImage(data: dude.image)!.applyFilter(selectedFilter)
        }
        
        dudesDataSource = UICollectionViewDiffableDataSource<Section, Dude>(collectionView: dudesCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Dude) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: dudeCellRegistration, for: indexPath, item: identifier)
        }
        
        let filterCellRegistration  = UICollectionView.CellRegistration
        <FilterCell, Int> { (cell, indexPath, identifier) in
            cell.label.text = String(format: "%02d", indexPath.row + 1)
        }
        
        filtersDataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: filtersCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: filterCellRegistration, for: indexPath, item: identifier)
        }

        // dudes initial data
        dudesSnapshot = NSDiffableDataSourceSnapshot<Section, Dude>()
        dudesSnapshot.appendSections([.dudes])
        dudesDataSource.apply(dudesSnapshot, animatingDifferences: false)
        
        // filters initial data
        let filters = Filter.allCases.map { $0.rawValue }
        var filtersSnapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        filtersSnapshot.appendSections([0])
        filtersSnapshot.appendItems(filters)
        filtersDataSource.apply(filtersSnapshot, animatingDifferences: false)
    }
}



// MARK: - Infinite scroll
extension DudesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (dudesCollectionView.contentSize.height - controlsView.bounds.height
                        - scrollView.frame.size.height) {
            if isGenerating == false {
                generateDudes()
            }
        }
    }
}



// MARK: - collectionView selections
extension DudesViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return dudesCollectionView.indexPathsForSelectedItems!.count < selectedDudesLimit
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dudesCollectionView {
            selectedCells.insert(indexPath)
            let cell = dudesCollectionView.cellForItem(at: indexPath) as! DudeCell
            var selectedDude = dudesDataSource.itemIdentifier(for: indexPath)
            selectedDude?.image = (cell.imageView.image?.pngData())!
            selectedDudes.insert(selectedDude!)
            selectedDudes.count > 0 ? createStickerpackButton.isEnabled = true : nil
            selectedDudes.count == selectedDudesLimit ? selectedLabel.shake() : nil
            let selectedDudesCount = String(format: "%02d", selectedDudes.count)
            selectedLabel.text = "\(selectedDudesCount)/\(selectedDudesLimit) SELECTED"
        }

        else if collectionView == filtersCollectionView {
            selectedFilter = Filter.allCases[indexPath.row]
            DispatchQueue.main.async() { [self] in
                dudesDataSource.apply(dudesSnapshot, animatingDifferences: false)
                for indexPath in selectedCells {
                    dudesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == dudesCollectionView {
            selectedCells.remove(indexPath)
            let deselectedDude = dudesDataSource.itemIdentifier(for: indexPath)
            selectedDudes.remove(deselectedDude!)
            selectedDudes.count == 0 ? createStickerpackButton.isEnabled = false : nil
            let selectedDudesCount = String(format: "%02d", selectedDudes.count)
            selectedLabel.text = "\(selectedDudesCount)/\(selectedDudesLimit) SELECTED"
        }
    }
}







