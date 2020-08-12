//
//  LocalNotification+CoreDataProperties.swift
//  
//
//  Created by Aghil C M on 29/01/18.
//
//

import Foundation
import CoreData


extension LocalNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalNotification> {
        return NSFetchRequest<LocalNotification>(entityName: "LocalNotification")
    }

    @NSManaged public var day: String?
    @NSManaged public var id: String?
    @NSManaged public var time: String?

}
