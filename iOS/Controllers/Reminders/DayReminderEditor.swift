//
//  DayReminderEditor.swift
//  CarShuffle
//
//  Created by deeje cooley on 5/21/21.
//

import Eureka
import CoreData
import CloudCore
import SwiftDate

class DayReminderEditor: FormViewController {
    
    var persistentContainer: NSPersistentContainer
    var carID: NSManagedObjectID
    var reminderID: NSManagedObjectID?
    
    enum Keys: String {
        case weekday
        case hour
        
        func key() -> String {
            return rawValue
        }
        
        func title() -> String {
            return rawValue.capitalized
        }
    }
    
    init(persistentContainer: NSPersistentContainer, carID: NSManagedObjectID, reminderID: NSManagedObjectID?) {
        self.persistentContainer = persistentContainer
        self.carID = carID
        self.reminderID = reminderID
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(doSave))
        
        var reminderEntity: Reminder?
        if reminderID != nil {
            reminderEntity = (try? persistentContainer.viewContext.existingObject(with: reminderID!)) as? Reminder
        }
        
        form
            +++ Section()
            
            <<< PickerInlineRow<WeekDay>(Keys.weekday.key()) { row in
                row.title = Keys.weekday.title()
                row.options = WeekDay.allCases
                row.displayValueFor = { rowValue in
                    return rowValue?.name()
                }
                row.value = row.options[1]
            }
            
            <<< PickerInlineRow<Int>(Keys.hour.key()) { row in
                row.title = Keys.hour.title()
                row.options = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
                row.value = row.options[3]
            }
            
            +++ Section("")
        
            <<< DestructiveButtonRow {
                $0.title = "Delete"
                $0.hidden = .function([]) { form in
                    return reminderEntity == nil
                }
            }
            .onCellSelection { [weak self] (cell, row) in
                self?.confirmDelete()
            }

        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20

    }
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This will be permanently removed this reminder from all devices", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.persistentContainer.performBackgroundPushTask { moc in
                if let reminderEntity = try? moc.existingObject(with: self.reminderID!) {
                    moc.delete(reminderEntity)
                    try? moc.save()
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirm)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func doCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doSave() {
        let values = form.values()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // Enable or disable features based on authorization.
        }
        
        persistentContainer.performBackgroundPushTask { moc in
            let carEntity = (try! moc.existingObject(with: self.carID)) as! Car
            
            var reminderEntity: Reminder?
            if self.reminderID != nil {
                reminderEntity = (try? moc.existingObject(with: self.reminderID!)) as? Reminder
            }
            if reminderEntity == nil {
                reminderEntity = Reminder(context: moc)
                
                if let oldReminderEntity = carEntity.reminder {
                    moc.delete(oldReminderEntity)
                    carEntity.reminder = nil
                }
                carEntity.reminder = reminderEntity
            }
            
            let calendar = Calendar.current
            let today = Date().dateAtStartOf(.day)
            
            let weekday: WeekDay = (values[Keys.weekday.key()] as? WeekDay)!
            let nextWeekday = today.nextWeekday(weekday)
            
            var moveByComponents = nextWeekday.dateComponents
            moveByComponents.second = 0
            moveByComponents.minute = 0
            moveByComponents.hour = (values[Keys.hour.key()] as? Int)!
            moveByComponents.timeZone = calendar.timeZone
            let moveBy = calendar.date(from: moveByComponents)
            
            reminderEntity?.moveBy = moveBy
            carEntity.lastUpdated = Date()
            
            do {
                try moc.save()
            } catch {
                print("Unexpected error: \(error).")
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
