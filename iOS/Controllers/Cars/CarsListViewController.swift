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
    
    var frc: NSFetchedResultsController<Car>!
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Car>!
    var diffableDataSource: UICollectionViewDiffableDataSource<String, Car>!
    
    var changedCars: [Car] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter
    }()
    
    static func storyboardName() -> String {
        return "CarsListView"
    }
    
    init?(coder: NSCoder, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
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
        updateSnapshot()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<String, Car>(collectionView: collectionView) { [weak self] collectionView, indexPath, car in
            guard let self = self else { return nil }
            
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: car)
        }
        collectionView.dataSource = diffableDataSource
    }
    
    func configureCellRegistration() {
        cellRegistration = .init { [unowned self] cell, _, car in
            var configuration = cell.defaultContentConfiguration()
            
            var text = car.name ?? "Car"
            if let reminder = car.reminder, let moveBy = reminder.moveBy {
                text = text + " @ " + self.dateFormatter.string(from: moveBy)
            }
            configuration.text = text
            cell.contentConfiguration = configuration
        }
    }
    
    func configureLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        
        configuration.trailingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            guard let car = self.diffableDataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
                let carEditor = CarEditor(persistentContainer: self.persistentContainer, carID: car.objectID)
                show(carEditor, sender: self)
                completion(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                confirmDelete(car.objectID)
                completion(true)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func configureFRC() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
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
    
    func updateSnapshot() {
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<String, Car>()
        frc.sections?.forEach { section in
            diffableDataSourceSnapshot.appendSections([section.name])
            diffableDataSourceSnapshot.appendItems(section.objects as! [Car], toSection: section.name)
        }
        diffableDataSourceSnapshot.reloadItems(changedCars)
        
        diffableDataSource?.apply(diffableDataSourceSnapshot, animatingDifferences: true)
    }
    
}

extension CarsListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .update, let car = anObject as? Car {
            changedCars.append(car)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
        
        changedCars.removeAll()
    }
    
}

extension CarsListViewController {
    
    func carAt(_ indexPath: IndexPath) -> Car {
        let sectionData = self.frc.sections?[indexPath.section]
        let userScan = sectionData?.objects![indexPath.item] as! Car
        
        return userScan
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let car = carAt(indexPath)
        
        let reminderID = car.reminder?.objectID
        
        let reminderEditor = ReminderEditor(persistentContainer: persistentContainer,
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
