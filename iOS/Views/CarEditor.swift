//
//  CarEditor.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData

struct CarEditor: View {
    
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.dismiss) var dismiss
    
    var carID: NSManagedObjectID?
    
    @State var carName = ""
    
    init(carID: NSManagedObjectID? = nil) {
        self.carID = carID
        
        if let carID, let car = try? persistentContainer.viewContext.existingObject(with: carID) as? Car {
            carName = car.name ?? ""
        }
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $carName)
        }
        .toolbar {
            ToolbarItem {
                Button(action: saveCar) {
                    Text("Save")
                }
            }
        }
    }
    
    func saveCar() {
        persistentContainer.performBackgroundPushTask { moc in
            let car: Car
            if let carID {
                car = try! moc.existingObject(with: carID) as! Car
            } else {
                car = Car(context: moc)
            }
            car.name = carName
            try? moc.save()
        }
        dismiss()
    }
    
}
