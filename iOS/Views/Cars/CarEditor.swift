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
    
    @State private var confirmingDelete: Bool = false
    
    init(car: Car? = nil) {
        self.car = car
        
        if let car {
            _carName = .init(initialValue: car.name ?? "")  // 2023-06 sigh, i'm already hacking shit
            self.carID = car.objectID
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $carName)
            }
            if carID != nil {
                Section {
                    Button("Delete", role: .destructive) {
                        confirmingDelete = true
                    }
                    .confirmationDialog("Are you sure?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                        Button("Delete car", role: .destructive) {
                            deleteCar()
                        }
                    }
                    message: {
                      Text("This will remove the car from everyone currently sharing it.")
                    }
                }
            }

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
            if car.name != carName {
                car.name = carName
                try? moc.save()
            }
        }
        dismiss()
    }
    
    private func deleteCar() {
        persistentContainer.performBackgroundPushTask { moc in
            if let carID, let car = try? moc.existingObject(with: carID) {
                moc.delete(car)
                
                try? moc.save()
            }
        }
        dismiss()
    }
    
}
