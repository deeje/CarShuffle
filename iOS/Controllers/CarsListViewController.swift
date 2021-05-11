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
    var lastObjectCount = 0
    
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
        cellRegistration = .init { cell, _, car in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = car.name
            cell.contentConfiguration = configuration
        }
    }
    
    func configureLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func configureFRC() {
        let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
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
        let objectCount = frc.fetchedObjects?.count ?? 0
        
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<String, Car>()
        frc.sections?.forEach { section in
            diffableDataSourceSnapshot.appendSections([section.name])
            diffableDataSourceSnapshot.appendItems(section.objects as! [Car], toSection: section.name)
        }
        diffableDataSource?.apply(diffableDataSourceSnapshot, animatingDifferences: lastObjectCount != objectCount)
        
        lastObjectCount = objectCount
    }
    
}

extension CarsListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
    }
    
}

extension CarsListViewController {
            
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    /*
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt contextMenuConfigurationForItemAtIndexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration {
        let userScan = userScanAt(contextMenuConfigurationForItemAtIndexPath)
        let userScanID = userScan.objectID
                
        let details = UIAction(title: "Details…", image: UIImage(systemName: "info.circle")) { _ in
            DispatchQueue.main.async {
                let vc = ScanDetailTableViewController.instantiate { coder in
                    return ScanDetailTableViewController(coder: coder, persistentContainer: self.persistentContainer, userScan: userScan)
                }
                self.show(vc, sender: self)
            }
        }
                
        let delete = UIAction(title: "Delete…", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            DispatchQueue.main.async {
                self.confirmDelete(userScanID)
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [favorite, details, tags, delete])
        }
    }
    */
    
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
        self.persistentContainer.performBackgroundTask { moc in
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
    
}
