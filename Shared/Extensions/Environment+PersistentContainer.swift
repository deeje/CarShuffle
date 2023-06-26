//
//  Environment+PersistentContainer.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData

struct PersistantContainerKey: EnvironmentKey {
    
    static let defaultValue = PersistenceController.shared.container
    
}

extension EnvironmentValues {
    
    var persistentContainer: NSPersistentContainer {
        get {
            return self[PersistantContainerKey.self]
        }
        set {
            self[PersistantContainerKey.self] = newValue
        }
    }
        
}
