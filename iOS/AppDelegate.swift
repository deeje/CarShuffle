//
//  AppDelegate.swift
//  CarShuffle
//
//  Created by deeje cooley on 4/24/21.
//

import UIKit
import CoreData
import CloudKit
import CloudCore
import Connectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer.CarShuffle()
        let viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.name = "viewContext"
        viewContext.transactionAuthor = "App"
        
        return container
    }()
    
    var connectivity: Connectivity?
    
    var remindersObserver: RemindersObserver?
    
    #if DEBUG
    var justLaunched = false
    #endif
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.registerForRemoteNotifications()
        
        configureUserNotifications()
        
        configureCloudCore()
        
        remindersObserver = RemindersObserver(persistentContainer: persistentContainer)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

// MARK: CloudKit

extension AppDelegate {
    
    #if DEBUG
    func applicationDidBecomeActive(_ application: UIApplication) {
        if justLaunched {
            justLaunched = false
            return
        }
        
        CloudCore.pull(to: persistentContainer, error: nil) { }
    }
    #endif
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CloudCore.isCloudCoreNotification(withUserInfo: userInfo) {
            CloudCore.pull(using: userInfo, to: persistentContainer, error: nil) { fetchResult in
                completionHandler(fetchResult.uiBackgroundFetchResult)
            }
        }
    }
    
    func configureCloudCore() {
        CloudCore.enable(persistentContainer: persistentContainer)
        
        let connectivityChanged: (Connectivity) -> Void = { connectivity in
            let online : [ConnectivityStatus] = [.connected, .connectedViaCellular, .connectedViaWiFi]
            CloudCore.isOnline = online.contains(connectivity.status)
        }
        
        connectivity = Connectivity(shouldUseHTTPS: false)
        connectivity?.whenConnected = connectivityChanged
        connectivity?.whenDisconnected = connectivityChanged
        connectivity?.startNotifier()
    }
    
}

// MARK: User Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func configureUserNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .provisional, .sound]) { granted, error in
            // Enable or disable features based on authorization.
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // TODO: show notification settings
    }
    
}
