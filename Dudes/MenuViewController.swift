//
//  MenuViewController.swift
//  Dudes
//
//  Created by Anton Evstigneev on 29.12.2020.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        applyInitialSnapshots()
        overrideUserInterfaceStyle = .dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }) { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
}

extension MenuViewController {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 25, width: view.frame.width, height: view.frame.height), collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    /// - Tag: ValueCellConfiguration
    func configureDataSource() {

        // list cell
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Menu> { (cell, indexPath, menuItem) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.image = menuItem.image
            contentConfiguration.text = menuItem.text!.uppercased()
            contentConfiguration.textProperties.font = UIFont(name: "Menlo", size: 16.0)!
            contentConfiguration.textProperties.color = UIColor(named: "AccentColor")!
            cell.contentConfiguration = contentConfiguration
            var background = UIBackgroundConfiguration.clear()
            background.backgroundColor = .black
            cell.backgroundConfiguration = background
            cell.accessories = [.disclosureIndicator()]
        }
        
        // data source
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.Menu)
        }
    }
    
    static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.clear()
        background.cornerRadius = 10
        if state.isHighlighted || state.isSelected {
            // Set nil to use the inherited tint color of the cell when highlighted or selected
            background.backgroundColor = nil
            
            if state.isHighlighted {
                // Reduce the alpha of the tint color to 30% when highlighted
                background.backgroundColorTransformer = .init { $0.withAlphaComponent(0.3) }
            }
        }
        return background
    }
    
    func applyInitialSnapshots() {

        for category in Menu.Category.allCases.reversed() {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let items = category.MenuItems.map { Item(Menu: $0, title: String(describing: category)) }
            sectionSnapshot.append(items)
            dataSource.apply(sectionSnapshot, to: category, animatingDifferences: false)
        }
    }
}

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuItem = self.dataSource.itemIdentifier(for: indexPath)?.Menu else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        if menuItem.text == "Subscription" {
            self.performSegue(withIdentifier: "SubscriptionViewController", sender: (Any).self)
        }
        if menuItem.text == "Feedback" {
            sendFeedback()
        }
        if menuItem.text == "About" {
            self.performSegue(withIdentifier: "AboutViewController", sender: (Any).self)
        }
    }
}

extension MenuViewController: MFMailComposeViewControllerDelegate {
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.view.tintColor = .systemBlue
            mail.overrideUserInterfaceStyle = .dark
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hi@getdudesapp.com"])
            mail.setSubject("Feedback")
            mail.setMessageBody("<br><br><br><p style='color:gray;'>\(UIDevice().type), iOS: \(getOSInfo())",
                                isHTML: true)

            present(mail, animated: true)
        } else {
            print("Error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
