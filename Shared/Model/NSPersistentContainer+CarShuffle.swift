//
//  NSPersistentContainer+CarShuffle.swift
//  CarShuffle
//
//  Created by deeje cooley on 3/9/21.
//  Copyright © 2021 deeje LLC All rights reserved.
//

import CoreData

struct Identifiers {
    
    static let appGroup = "group.com.deeje.CarShuffle"
    static let database = "CarShuffle"
    
    static let carWidget = "CarWidget"
}

extension NSPersistentContainer {
        
    static public func CarShuffle(inMemory: Bool = false) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: Identifiers.database)
        
        let storeURL: URL
        if inMemory {
            storeURL = URL(fileURLWithPath: "/dev/null")
        } else {
            storeURL = URL.storeURL(for: Identifiers.appGroup, databaseName: Identifiers.database)
        }
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        let viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.name = "viewContext"
        
        if inMemory {
            let car = Car(context: viewContext)
            car.name = "test car"
            
            try? viewContext.save()
        }
        
        return container
    }
    
}
