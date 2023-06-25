//
//  CarsList.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData

struct CarsList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Car.name, ascending: true)],
        animation: .default)
    private var cars: FetchedResults<Car>

    var body: some View {
        NavigationView {
            List {
                ForEach(cars) { car in
                    Text(car.name!)
                }
                .onDelete(perform: deleteCars)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addCar) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addCar() {
        withAnimation {
            let car = Car(context: viewContext)
            car.name = Date().toString()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteCars(offsets: IndexSet) {
        withAnimation {
            offsets.map { cars[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    CarsList()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
