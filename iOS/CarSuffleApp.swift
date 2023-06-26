//
//  CarSuffleApp.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData

@main
struct CarShuffleApp: App {
    
    let persistentContainer = PersistenceController.shared.container
    
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CarsList()
            }
            .environment(\.persistentContainer, persistentContainer)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
