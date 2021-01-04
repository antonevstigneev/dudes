//
//  Menu.swift
//  Dudes
//
//  Created by Anton Evstigneev on 30.12.2020.
//

import UIKit

struct Menu: Hashable {
    
    enum Category: CaseIterable {
        case about, subscription
    }
    
    let image: UIImage?
    let text: String?
    let category: Category
    private let identifier = UUID()
    
    init(imageName: String? = nil, text: String? = nil, category: Category) {
        self.text = text
        self.category = category
        if let systemName = imageName {
            self.image = UIImage(systemName: systemName)
        } else {
            self.image = nil
        }
    }
}

extension Menu.Category {
    
    var MenuItems: [Menu] {
        switch self {
        case .about:
            return [
                Menu(imageName: nil, text: "Feedback", category: self),
                Menu(imageName: nil, text: "About", category: self),
            ]

        case .subscription:
            return [
                Menu(imageName: nil, text: "Subscription", category: self),
            ]
        }
    }
}

typealias Section = Menu.Category

struct Item: Hashable {
    let title: String
    let Menu: Menu
    init(Menu: Menu, title: String) {
        self.Menu = Menu
        self.title = title
    }
    private let identifier = UUID()
}
