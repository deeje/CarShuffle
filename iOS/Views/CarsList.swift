//
//  CarsList.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData

struct CarsList: View {
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Car.name, ascending: true)],
        animation: .default)
    private var cars: FetchedResults<Car>
    
    var body: some View {
        List {
            ForEach(cars) { car in
                NavigationLink(value: car) {
                    HStack(alignment: .top) {
                        Image(systemName: "car")
                        Text(car.name!)
                    }
                }
                
            }
            .onDelete(perform: deleteCars)
        }
        .toolbar {
            ToolbarItem {
                Button(action: addCar) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .navigationDestination(for: Car.self) { car in
            
        }
    }
    
    private func addCar() {
        persistentContainer.performBackgroundPushTask { moc in
            let car = Car(context: moc)
            car.name = Date().toString()
            try? moc.save()
        }
    }
    
    private func deleteCars(offsets: IndexSet) {
        let carIDs = offsets.map { cars[$0].objectID }
        persistentContainer.performBackgroundPushTask { moc in
            carIDs.forEach { carID in
                if let car = try? moc.existingObject(with: carID) {
                    moc.delete(car)
                }
            }
            try? moc.save()
        }
    }
}

#Preview {
    NavigationView {
        CarsList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
