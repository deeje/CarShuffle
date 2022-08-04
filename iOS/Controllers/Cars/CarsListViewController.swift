//
//  CarsListViewController.swift
//  CarShuffle
//
//  Created by deeje cooley on 5/11/21.
//

import UIKit
import CoreData

class CarsListViewController: UICollectionViewController, Storyboarded {
    
    let persistentContainer: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    
    var frc: NSFetchedResultsController<Car>!
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID>!
    var diffableDataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd, ha"
        return formatter
    }()
    
    static func storyboardName() -> String {
        return "CarsListView"
    }
    
    init?(coder: NSCoder, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.viewContext = persistentContainer.viewContext
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        configureCellRegistration()
        
        configureDataSource()
        
        configureFRC()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        collectionView.delegate = self
    }
    
    func configureLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        
        configuration.trailingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            guard let carID = self.diffableDataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
                let carEditor = CarEditor(persistentContainer: self.persistentContainer, carID: carID)
                self.show(carEditor, sender: self)
                completion(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                self.confirmDelete(carID)
                completion(true)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func configureCellRegistration() {
        cellRegistration = .init { [unowned self] cell, _, carID in
            var configuration = cell.defaultContentConfiguration()
            
            let car = try! viewContext.existingObject(with: carID) as! Car
            
            var text = car.name ?? "Car"
            if let reminder = car.reminder, let moveBy = reminder.moveBy {
                text = text + " @ " + self.dateFormatter.string(from: moveBy)
            }
            configuration.text = text
            cell.contentConfiguration = configuration
        }
    }
    
    func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] collectionView, indexPath, carID in
            guard let self = self else { return nil }
            
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: carID)
        }
        collectionView.dataSource = diffableDataSource
    }
    
    func configureFRC() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        self.frc = frc
        
        do {
            try frc.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
}

extension CarsListViewController: NSFetchedResultsControllerDelegate {
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension CarsListViewController {
    
    func carAt(_ indexPath: IndexPath) -> Car {
        let sectionData = self.frc.sections?[indexPath.section]
        let car = sectionData?.objects![indexPath.item] as! Car
        
        return car
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let car = carAt(indexPath)
        
        let reminderID = car.reminder?.objectID
        
        let reminderEditor = DayReminderEditor(persistentContainer: persistentContainer,
                                            carID: car.objectID,
                                            reminderID: reminderID)
        show(reminderEditor, sender: self)
    }
        
    func confirmDelete(_ carID: NSManagedObjectID) {
        let alert = UIAlertController(title: "Delete this car?", message: "This cannot be undone", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delete(carID)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func delete(_ carID: NSManagedObjectID) {
        self.persistentContainer.performBackgroundPushTask { moc in
            if let car = try? moc.existingObject(with: carID) as? Car {
                do {
                    moc.delete(car)
                    try moc.save()
                } catch {
//                    os_log("delete failed with error %@.", log: OSLog.user, type: .debug, error as CVarArg)
                }
            }
        }
    }
    
    @objc
    func add() {
        let carEditor = CarEditor(persistentContainer: persistentContainer, carID: nil)
        show(carEditor, sender: self)
    }
    
}
