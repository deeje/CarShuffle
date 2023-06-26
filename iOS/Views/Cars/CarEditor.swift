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
    
    var car: Car?
    var carID: NSManagedObjectID?
    
    @State var carName = ""
    
    init(car: Car? = nil) {
        self.car = car
        
        if let car {
            _carName = .init(initialValue: car.name ?? "")  // 2023-06 sigh, i'm already hacking shit
            self.carID = car.objectID
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
        .navigationTitle("Car Info")
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
