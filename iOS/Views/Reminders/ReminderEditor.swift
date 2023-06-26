//
//  ReminderEditor.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/26/23.
//

import SwiftUI
import CoreData
import SwiftDate

extension WeekDay: Identifiable {
    public var id: Self { self }
}

extension Int: Identifiable {
    public var id: Self { self }
}

struct ReminderEditor: View {
        
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.dismiss) var dismiss
    
    var car: Car
    var carID: NSManagedObjectID
    var reminderID: NSManagedObjectID?
    
    let calendar = Calendar.current
    
    let hourOptions = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    
    @State var selectedDay: WeekDay = .wednesday
    @State var selectedHour: Int = 9
    
    init(car: Car) {
        self.car = car
        self.carID = car.objectID
        
        if let reminder = car.reminder, let moveBy = reminder.moveBy {
            self.reminderID = reminder.objectID
            
            let dayIndex = calendar.ordinality(of: .day, in: .weekOfMonth, for: moveBy) ?? 1
            _selectedDay = .init(initialValue: WeekDay.allCases[dayIndex - 1])
            
            let hour = calendar.ordinality(of: .hour, in: .day, for: moveBy) ?? 1
            _selectedHour = .init(initialValue: (hour - 1))
        }
    }
    
    var body: some View {
        Form {
            Picker("Day", selection: $selectedDay) {
                ForEach(WeekDay.allCases) { day in
                    Text(day.name()).tag(day)
                }
            }
            Picker("Hour", selection: $selectedHour) {
                ForEach(hourOptions) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            if reminderID != nil {
                Button("Delete") {
                    deleteReminder()
                }
            }
        }
        .navigationTitle("Reminder")
        .toolbar {
            ToolbarItem {
                Button(action: saveReminder) {
                    Text("Save")
                }
            }
        }
    }
    
    func saveReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // Enable or disable features based on authorization.
        }
        
        persistentContainer.performBackgroundPushTask { moc in
            let reminder: Reminder
            if let reminderID {
                reminder = try! moc.existingObject(with: reminderID) as! Reminder
            } else {
                reminder = Reminder(context: moc)
                reminder.car = try! moc.existingObject(with: carID) as! Car
            }
            
            let today = Date().dateAtStartOf(.day)
            let nextWeekday = today.nextWeekday(selectedDay)
            
            var moveByComponents = nextWeekday.dateComponents
            moveByComponents.second = 0
            moveByComponents.minute = 0
            moveByComponents.hour = selectedHour
            moveByComponents.timeZone = calendar.timeZone
            let moveBy = calendar.date(from: moveByComponents)
            
            reminder.moveBy = moveBy
            reminder.car!.lastUpdated = Date()
            
            try? moc.save()
        }
        dismiss()
    }
    
    func deleteReminder() {
        persistentContainer.performBackgroundPushTask { moc in
            guard let reminderID, let reminder = try? moc.existingObject(with: reminderID) as? Reminder else {
                assertionFailure("trying to delete a reminder that doesn't exist?!")
                return
            }
            
            moc.delete(reminder)

            try? moc.save()
        }
        dismiss()
    }
    
}

//#Preview {
//    ReminderEditor()
//}
