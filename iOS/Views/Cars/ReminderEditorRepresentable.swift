//
//  ReminderEditorRepresentable.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/26/23.
//

import SwiftUI
import CoreData

struct ReminderEditorRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ReminderEditor
    
    let persistentContainer: NSPersistentContainer
    let carID: NSManagedObjectID
    let reminderID: NSManagedObjectID?
    
    @MainActor func makeUIViewController(context: Self.Context) -> ReminderEditor {
        return ReminderEditor(persistentContainer: persistentContainer, carID: carID, reminderID: reminderID)
    }
    
    func updateUIViewController(_ uiViewController: ReminderEditor, context: Context) {
        //
    }

}
