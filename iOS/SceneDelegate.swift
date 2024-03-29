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
        
    var window: UIWindow?
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareResultBlock = { meta, result in
            guard let recordID = meta.hierarchicalRootRecordID else { return }
            
            CloudCore.pull(rootRecordID: recordID, container: PersistenceController.shared.container, error: nil) { }
        }
        acceptShareOperation.acceptSharesResultBlock = { result in
            // N/A
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
}

