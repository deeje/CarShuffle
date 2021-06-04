//
//  SceneDelegate.swift
//  CarShuffle
//
//  Created by deeje cooley on 4/24/21.
//

import UIKit
import CoreData
import CloudCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var persistentContainer: NSPersistentContainer!
    
    var window: UIWindow?
    var launchCoordinator: LaunchCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        
        let navigationContoller = UINavigationController()
        navigationContoller.navigationBar.isTranslucent = true
        
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        window.rootViewController = navigationContoller
        window.makeKeyAndVisible()
        window.tintColor = .systemGreen
        
        launchCoordinator = LaunchCoordinator(navigationController: navigationContoller,
                                              persistentContainer: persistentContainer)
        launchCoordinator?.start()
        
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = { meta, share, error in
            CloudCore.pull(rootRecordID: meta.rootRecordID, container: self.persistentContainer, error: nil) { }
        }
        acceptShareOperation.acceptSharesCompletionBlock = { error in
            // N/A
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
}

