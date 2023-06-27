//
//  CarEditor.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/25/23.
//

import SwiftUI
import CoreData
import CloudKit
import CloudCore

struct CarEditor: View {
    
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.dismiss) var dismiss
    
    var car: Car?
    var carID: NSManagedObjectID?
    
    @State var carName = ""
    
    @State private var iCloudEnabled: Bool = false
    @State private var isEditable: Bool = false
    
    @State private var confirmingDelete: Bool = false
    
    @State private var carShare: CKShare?
    @State private var showSharing: Bool = false
    
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
                    .disabled(!isEditable)
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
                }
            }

        }
        .toolbar {
            if iCloudEnabled && carShare != nil {
                ToolbarItem {
                    Button(action: {
                        showSharing = true
                    }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            if isEditable {
                ToolbarItem {
                    Button(action: saveCar) {
                        Text("Save")
                    }
                }
            }
        }
        .navigationTitle("Car Info")
        .task {
            CloudCore.iCloudAvailable { available in
                iCloudEnabled = available
            }
            
            if let car {
                car.fetchEditablePermissions { canEdit in
                    isEditable = canEdit
                }
                car.fetchShareRecord(in: persistentContainer) { share, error in
                    carShare = share
                }
            } else {
                isEditable = true
            }
        }
        .sheet(isPresented: $showSharing) {
            if let car, let carShare {
                CloudCoreSharingView(persistentContainer: persistentContainer, object: car, share: carShare, permissions: [.allowReadWrite, .allowPrivate])
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
