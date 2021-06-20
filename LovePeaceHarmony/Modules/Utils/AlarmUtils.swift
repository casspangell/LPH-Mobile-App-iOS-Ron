//
//  AlarmUtils.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 05/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import UIKit
import CoreData
import UserNotifications

class AlarmUtils {
    
    static func saveCoreDataReminder(scheduledDate: Date, reminderId: String, hour: String, minute: String, amPm: String, repeatDays: String?, fullTime: String) {
        var repeatDays = repeatDays
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.reminder, in: managedContext)!
        let reminder = NSManagedObject(entity: entity, insertInto: managedContext)
        reminder.setValue(reminderId, forKeyPath: CoreDataProperty.reminderId)
        reminder.setValue(hour, forKeyPath: CoreDataProperty.hour)
        reminder.setValue(minute, forKeyPath: CoreDataProperty.minute)
        reminder.setValue(amPm, forKeyPath: CoreDataProperty.amPm)
        reminder.setValue(fullTime, forKeyPath: CoreDataProperty.fullTime)
        if repeatDays == nil {
            repeatDays = "Off"
        }
        reminder.setValue(repeatDays!, forKeyPath: CoreDataProperty.repeatDays)
        reminder.setValue(true, forKey: CoreDataProperty.isActivated)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("saving repeat days \(repeatDays)")
        calculateAndSchedulingRepeatedLocalNotification(scheduledDate: scheduledDate, hour: hour, minute: minute, repeatDays: repeatDays!)
        
    }
    
    static func updateCoreDataReminder(reminder: Reminder, newDate: Date, oldTime: String, isOn: Bool) {
        if reminder.repeatDays == nil {
            reminder.repeatDays = "Off"
        }
        reminder.isActivated = isOn
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.reminderId + " == %@", reminder.reminderId!)
        var savedReminderList = try? managedContext.fetch(fetchRequest) as? [Reminder] ?? [Reminder]()
        print(reminder.reminderId!)
        print((savedReminderList?.count)!)
        if savedReminderList?.count == 1 {
            savedReminderList![0] = reminder
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        cancelAndDeleteScheduledLocalNotifications(time: oldTime)
        if reminder.isActivated {
            calculateAndSchedulingRepeatedLocalNotification(scheduledDate: newDate, hour: reminder.hour!, minute: reminder.minute!, repeatDays: reminder.repeatDays!)
        }
    }
    
    static func deleteCoreDataReminder(reminder: Reminder) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.reminderId + " == %@", reminder.reminderId!)
        var savedReminderList = try? managedContext.fetch(fetchRequest) as? [Reminder] ?? [Reminder]()
        if savedReminderList?.count == 1 {
            managedContext.delete((savedReminderList?[0])!)
        }
        cancelAndDeleteScheduledLocalNotifications(time: String(format: "%02d:%02d", Int(reminder.hour!)!, Int(reminder.minute!)!))
    }
    
    public static func fetchCoreDataReminderList() ->[Reminder] {
        var reminderList = [Reminder]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return reminderList
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        let fetchedList = try? managedContext.fetch(fetchRequest) as! [Reminder]
        reminderList.append(contentsOf: fetchedList ?? [Reminder]())
        return reminderList
    }

    // Calculating repeating alarms
    private static func calculateAndSchedulingRepeatedLocalNotification(scheduledDate: Date, hour: String, minute: String, repeatDays: String) {
        
        let dateFormatted = String(format: "%02d:%02d", Int(hour)!, Int(minute)!)
        if repeatDays == "Off" {
            let identifier = String(arc4random())
            print(scheduledDate)
            saveLocalNotification(time: dateFormatted, identifier: identifier, day: "Off")
            scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .off)
        } else if repeatDays == "Every Day" {
            let identifier = String(arc4random())
            saveLocalNotification(time: dateFormatted, identifier: identifier, day: "EveryDay")
            scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .everyDay)
        } else {
            let daysList = repeatDays.components(separatedBy: " ")
            for day in daysList {
                let identifier = String(arc4random())
                if day == "Sun" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "sun")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .sun)
                } else if day == "Mon" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "mon")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .mon)
                } else if day == "Tue" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "tue")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .tue)
                } else if day == "Wed" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "wed")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .wed)
                } else if day == "Thu" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "thu")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .thu)
                } else if day == "Fri" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "fri")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .fri)
                } else if day == "Sat" {
                    saveLocalNotification(time: dateFormatted, identifier: identifier, day: "sat")
                    scheduleLocalNotification(scheduledDate, identifier: identifier, repeatType: .sat)
                }
            }
        }
    }
    
    // Cancelling scheduled alarms
    private static func cancelAndDeleteScheduledLocalNotifications(time: String) {
        let localNotificationList = AlarmUtils.fetchLocalNotificationList(time: time)
        var identifierList = [String]()
        for localNotification in localNotificationList {
            identifierList.append((localNotification.id)!)
        }

//        Remove registered local notifications
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifierList)

//        Deleting local notification from core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.localNotification)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.time + " == %@", time)
        var savedReminderList = try? managedContext.fetch(fetchRequest) as? [LocalNotification] ?? [LocalNotification]()
        if savedReminderList?.count == 1 {
            managedContext.delete((savedReminderList?[0])!)
        }
        
    }
    
    public static func isSameReminderExist(hour: String, minute: String, amPm: String) -> Bool {
        var isExist = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return isExist
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.hour + " == %@ AND " + CoreDataProperty.minute + " == %@ AND " + CoreDataProperty.amPm + " == %@ ", hour, minute, amPm)
        let fetchedList = try? managedContext.fetch(fetchRequest) as! [Reminder]
        let reminderList = fetchedList ?? [Reminder]()
        isExist = reminderList.count > 0
        return isExist
    }
    
    private static func saveLocalNotification(time: String, identifier: String, day: String) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.localNotification, in: managedContext)!
        let reminder = NSManagedObject(entity: entity, insertInto: managedContext)
        reminder.setValue(identifier, forKeyPath: CoreDataProperty.id)
        reminder.setValue(day, forKeyPath: CoreDataProperty.day)
        reminder.setValue(time, forKeyPath: CoreDataProperty.time)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
    public static func fetchLocalNotificationList(time: String) ->[LocalNotification] {
        var localNotificationList = [LocalNotification]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return localNotificationList
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.localNotification)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.time + " == %@", time)
        let fetchedList = try? managedContext.fetch(fetchRequest) as! [LocalNotification]
        localNotificationList.append(contentsOf: fetchedList ?? [LocalNotification]())
        return localNotificationList
    }
    
    /*
    public static func deleteLocalNotificationList(notificationList: [LocalNotification]) {
        var time = String()
        var identifierList = [String]()
        for localNotification in notificationList {
            time = localNotification.time!
            identifierList.append(localNotification.id!)
        }
//        Remove registered local notifications
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifierList)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CORE_DATA_ENTITY_LOCAL_NOTIFICATION)
        fetchRequest.predicate = NSPredicate(format: CORE_DATA_PROPERTY_TIME + " == %@", time)
        var savedReminderList = try? managedContext.fetch(fetchRequest) as? [LocalNotification] ?? [LocalNotification]()
        if savedReminderList?.count == 1 {
            managedContext.delete((savedReminderList?[0])!)
        }
        
        
    }*/
    
    private static func scheduleLocalNotification(_ scheduledDate: Date, identifier: String, repeatType: AlarmRepeat) {
        let content = UNMutableNotificationContent()
        let scheduledDateComponent = Calendar.current.dateComponents([.hour, .minute, .day, .weekday], from: scheduledDate)
        content.title = NSString.localizedUserNotificationString(forKey: "Chant reminder", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: NSLocalizedString(AlertMessage.timeToChant, comment: "") , arguments: nil)
        content.sound = UNNotificationSound.default()
        
        content.badge = 0
        content.categoryIdentifier = "LovePeaceHarmony"
        
        
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: scheduledDate)
        dateComponents.minute = Calendar.current.component(.minute, from: scheduledDate)
        dateComponents.second = 0
        var isAlarmRepeatable = false
        if repeatType != .off {
            if repeatType == .everyDay {
                isAlarmRepeatable = true
            } else {
                dateComponents.weekday = repeatType.rawValue
                isAlarmRepeatable = true
            }
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isAlarmRepeatable)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
    }
    
}

enum AlarmRepeat: Int {
    case everyDay
    case sun
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    case off
}
