//
//  Reminder+CoreDataProperties.swift
//  
//
//  Created by Aghil C M on 29/01/18.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var amPm: String?
    @NSManaged public var fullTime: String?
    @NSManaged public var hour: String?
    @NSManaged public var isActivated: Bool
    @NSManaged public var minute: String?
    @NSManaged public var reminderId: String?
    @NSManaged public var repeatDays: String?

}
