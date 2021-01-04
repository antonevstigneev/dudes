//
//  Sticker+CoreDataProperties.swift
//  Dudes
//
//  Created by Anton Evstigneev on 17.12.2020.
//
//

import Foundation
import CoreData


extension Sticker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sticker> {
        return NSFetchRequest<Sticker>(entityName: "Sticker")
    }

    @NSManaged public var emotion: String?
    @NSManaged public var image: Data?
    @NSManaged public var id: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var stickerpack: Stickerpack?

}

extension Sticker : Identifiable {

}
