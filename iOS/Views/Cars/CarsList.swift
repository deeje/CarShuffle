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
    
    @State private var showingEditor = false
    
    var body: some View {
        List(cars, id: \.objectID) { car in
            NavigationLink(value: car) {
                VStack {
                    HStack(alignment: .top) {
                        Image(systemName: "car")
                        Text(car.name!)
                    }
                    if let reminder = car.reminder, let moveBy = reminder.moveBy {
                        Text(moveBy.toString())
                    }
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Cars")
        .toolbar {
            ToolbarItem {
                Button(action: addCar) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .navigationDestination(for: Car.self) { car in
            ReminderForm(car: car)
        }
        .navigationDestination(isPresented: $showingEditor) {
            CarEditor(car: nil)
        }
    }
    
    private func addCar() {
        showingEditor = true
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
