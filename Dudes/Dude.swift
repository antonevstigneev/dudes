//
//  Dude.swift
//  Dudes
//
//  Created by Anton Evstigneev on 16.12.2020.
//

import UIKit
import CoreData

struct Dude: Hashable {
    let emotion: String
    var image: Data
    let id: String
    let timestamp: Date
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Dude, rhs: Dude) -> Bool {
        lhs.id == rhs.id
    }
}

