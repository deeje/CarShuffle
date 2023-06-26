//
//  CarsList.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData
import SwiftDate

extension Date {
    func inLocalTime() -> Date? {
        return Calendar.current.date(byAdding: .second,
                                     value: TimeZone.current.secondsFromGMT(),
                                     to: self)
    }
}

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
                HStack(alignment: .top) {
                    Image(systemName: "car")
                    VStack(alignment: .leading) {
                        Text(car.name!)
                        if let reminder = car.reminder, let moveBy = reminder.moveBy, let localMoveBy = moveBy.inLocalTime() {
                            Text(localMoveBy.toString(DateToStringStyles.dateTime(.short)))
                        }
                    }
                }
            }
            .swipeActions(edge: .leading) {
                NavigationLink(value: car.objectID) {
                    Text("Edit")
                }
            }
            .contextMenu {
                NavigationLink(value: car.objectID) {
                    Text("Edit")
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
            ReminderEditor(car: car)
        }
        .navigationDestination(for: NSManagedObjectID.self) { carID in
            CarEditor(car: (try! viewContext.existingObject(with: carID) as! Car))
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

//#Preview {
//    NavigationView {
//        CarsList()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
