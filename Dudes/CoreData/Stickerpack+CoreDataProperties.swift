//
//  Stickerpack+CoreDataProperties.swift
//  Dudes
//
//  Created by Anton Evstigneev on 17.12.2020.
//
//

import Foundation
import CoreData


extension Stickerpack {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stickerpack> {
        return NSFetchRequest<Stickerpack>(entityName: "Stickerpack")
    }

    @NSManaged public var id: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var stickers: NSSet?
    @NSManaged public var isInUpdateMode: NSNumber?
    @NSManaged public var isExported: NSNumber?
}

// MARK: Generated accessors for stickers
extension Stickerpack {

    @objc(addStickersObject:)
    @NSManaged public func addToStickers(_ value: Sticker)

    @objc(removeStickersObject:)
    @NSManaged public func removeFromStickers(_ value: Sticker)

    @objc(addStickers:)
    @NSManaged public func addToStickers(_ values: NSSet)

    @objc(removeStickers:)
    @NSManaged public func removeFromStickers(_ values: NSSet)

}

extension Stickerpack : Identifiable {

}
