//
//  DateReminderEditor.swift
//  CarShuffle
//
//  Created by deeje cooley on 5/17/21.
//

import Eureka
import CoreData
import CloudCore
import SwiftDate

class DateReminderEditor: FormViewController {
    
    var persistentContainer: NSPersistentContainer
    var carID: NSManagedObjectID
    var reminderID: NSManagedObjectID?
    
    enum Keys: String {
        case moveBy
        
        func key() -> String {
            return rawValue
        }
        
        func title() -> String {
            switch self {
            case .moveBy:
                return "Move By"
            }
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
            
            <<< DateTimeRow {
                $0.tag = Keys.moveBy.key()
                $0.title = Keys.moveBy.title()
                                
                $0.value = reminderEntity?.moveBy ?? (Date() + 3.minutes)
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
            reminderEntity?.moveBy = values[Keys.moveBy.key()] as? Date
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
