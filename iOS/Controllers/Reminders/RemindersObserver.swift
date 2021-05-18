//
//  GoalOPbserver.swift
//  CarShuffle
//
//  Created by deeje cooley on 05/18/2021.
//  Copyright © 2021 deeje LLC All rights reserved.
//

import CoreData
import UserNotifications
import WidgetKit

final class RemindersObserver: NSObject, NSFetchedResultsControllerDelegate {
    private let persistentContainer: NSPersistentContainer
    private let frc: NSFetchedResultsController<Reminder>
    
    var carIDs: [String] = []
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        let moc = persistentContainer.newBackgroundContext()
        moc.automaticallyMergesChangesFromParent = true
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "moveBy", ascending: false)]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: moc,
                                         sectionNameKeyPath: nil,
                                         cacheName: "RemindersObserver")
        
        super.init()
        
        frc.delegate = self
        try? frc.performFetch()
        
        cacheCarIDS()
    }
    
    func cacheCarIDS() {
        frc.managedObjectContext.perform {
            if let reminders = self.frc.fetchedObjects {
                self.carIDs = reminders.map { reminder in
                    return reminder.car!.uuid!
                }
            }
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        let noteCenter = UNUserNotificationCenter.current()
        
        func cleanup(uuid: String) {
            var identifiers = [uuid]
            for countdown in Countdown.allCases {
                identifiers.append(uuid + countdown.rawValue)
            }
            noteCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        switch type {
        case .delete:
            let uuidString = carIDs[indexPath!.item]
            cleanup(uuid: uuidString)
        case .update, .insert:
            guard let reminder = anObject as? Reminder, let car = reminder.car else { return }
            
            let uuidString = car.uuid!
            cleanup(uuid: uuidString)
            
            for countdown in Countdown.allCases {
                let content = UNMutableNotificationContent()
                content.categoryIdentifier = "reminderNotification"
                content.title = "Move the " + car.name!
                content.subtitle = "Parking expires in " + countdown.timeInterval().toString()
                
                let notificationDate = reminder.moveBy! - countdown.timeInterval()
                let components: Set<Calendar.Component> = [ .second, .minute, .hour, .day, .month, .year]
                let dateComponents = Calendar.current.dateComponents(components, from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: uuidString + countdown.rawValue, content: content, trigger: trigger)
                noteCenter.add(request) { error in
                    //
                }
            }
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "reminderNotification"
            content.title = "Move the " + car.name!
            content.subtitle = "Parking has expired!"
            
            let notificationDate = reminder.moveBy!
            let components: Set<Calendar.Component> = [ .second, .minute, .hour, .day, .month, .year]
            let dateComponents = Calendar.current.dateComponents(components, from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            noteCenter.add(request) { error in
                //
            }
        default:
            break
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: Identifiers.carWidget)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cacheCarIDS()
    }
    
}
