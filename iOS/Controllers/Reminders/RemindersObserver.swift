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
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let noteCenter = UNUserNotificationCenter.current()
        noteCenter.removeAllPendingNotificationRequests()
        
        guard let reminders = frc.fetchedObjects else { return }
        
        for reminder in reminders {
            guard let car = reminder.car, let uuidString = car.uuid else { continue }
            
            for countdown in Countdown.allCases {
                let content = UNMutableNotificationContent()
                content.categoryIdentifier = "reminderNotification"
                content.title = "Move the " + car.name!
                if countdown == .expired {
                    content.subtitle = "Parking has expired!"
                } else {
                    content.subtitle = "Parking expires in " + countdown.timeInterval().toString()
                }
                
                let notificationDate = reminder.moveBy! - countdown.timeInterval()
                let components: Set<Calendar.Component> = [ .second, .minute, .hour, .day, .month, .year]
                let dateComponents = Calendar.current.dateComponents(components, from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: uuidString + countdown.rawValue, content: content, trigger: trigger)
                noteCenter.add(request) { error in
                    //
                }
            }
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: Identifiers.carWidget)
    }
    
}
