//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Aghil C M on 31/01/18.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryId: String?
    @NSManaged public var favoritesCount: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var newsCount: String?
    @NSManaged public var title: String?
    @NSManaged public var unreadNewsCount: String?

}
