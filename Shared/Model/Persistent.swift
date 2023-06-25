//
//  Persistent.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()

    static var preview = PersistenceController(inMemory: true)
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer.CarShuffle(inMemory: inMemory)
    }
    
}
