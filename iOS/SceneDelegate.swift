//
//  SceneDelegate.swift
//  CarShuffle
//
//  Created by deeje cooley on 4/24/21.
//

import UIKit
import CoreData
import CloudKit
import CloudCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var persistentContainer: NSPersistentContainer!
    
    var window: UIWindow?
    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = scene as? UIWindowScene else { return }
//        
//        persistentContainer = PersistenceController.shared.container
//        
//        let navigationContoller = UINavigationController()
//        navigationContoller.navigationBar.isTranslucent = true
//        
//        let window = UIWindow(windowScene: windowScene)
//        window.backgroundColor = .systemBackground
//        window.rootViewController = navigationContoller
//        window.makeKeyAndVisible()
//        window.tintColor = .systemGreen
//        
//        self.window = window
//        
//        let carsList = CarsListViewController.instantiate { coder in
//            return CarsListViewController(coder: coder, persistentContainer: self.persistentContainer)
//        }
//        navigationContoller.setViewControllers([carsList], animated: false)
//    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareResultBlock = { meta, result in
            guard let recordID = meta.hierarchicalRootRecordID else { return }
            
            CloudCore.pull(rootRecordID: recordID, container: self.persistentContainer, error: nil) { }
        }
        acceptShareOperation.acceptSharesResultBlock = { result in
            // N/A
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
}

