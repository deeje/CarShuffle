//
//  Created by deeje cooley on 10/10/18.
//  Copyright © 2018 deeje LLC.  All rights reserved.
//

import Eureka
import CoreData
import CloudCore

final class DestructiveButtonRow : _ButtonRowOf<String>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    override func customUpdateCell() {
        super.customUpdateCell()
        cell.textLabel?.textColor = UIColor.red
    }
}

class CarEditor: FormViewController {
    
    var persistentContainer: NSPersistentContainer
    var carID: NSManagedObjectID?
    
    enum Keys: String {
        case name
        
        func key() -> String {
            return rawValue
        }
        
        func title() -> String {
            switch self {
            default:
                return rawValue.capitalized
            }
        }
    }
    
    init(persistentContainer: NSPersistentContainer, entryID: NSManagedObjectID?) {
        self.persistentContainer = persistentContainer
        self.carID = entryID
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(doSave))
        
        var carEntity: Car?
        if carID != nil {
            carEntity = (try? persistentContainer.viewContext.existingObject(with: carID!)) as? Car
        }
        
        form
            +++ Section()
            
            
            <<< TextRow() {
                $0.tag = Keys.name.key()
                $0.title = Keys.name.title()
                
                $0.value = carEntity?.name
            }
            
            +++ Section("")
        
            <<< DestructiveButtonRow {
                $0.title = "Delete"
                $0.hidden = .function([]) { form in
                    return carEntity == nil
                }
            }
            .onCellSelection { [weak self] (cell, row) in
                self?.confirmDelete()
            }

        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20

    }
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This will be permanently removed this car from all devices", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.persistentContainer.performBackgroundPushTask { moc in
                if let carEntity = try? moc.existingObject(with: self.carID!) {
                    moc.delete(carEntity)
                    try? moc.save()
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirm)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func doCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doSave() {
        let values = form.values()
        
        persistentContainer.performBackgroundPushTask { moc in
            var carEntity: Car?
            if self.carID != nil {
                carEntity = (try? moc.existingObject(with: self.carID!)) as? Car
            }
            if carEntity == nil {
                carEntity = Car(context: moc)
            }
            carEntity?.name = values[Keys.name.key()] as? String
            
            do {
                try moc.save()
            } catch {
                print("Unexpected error: \(error).")
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
