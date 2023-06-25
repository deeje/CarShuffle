//
//  LaunchCoordinator.swift
//  Car Shuffle
//
//  Created by deeje cooley on 10/28/19.
//  Copyright © 2021 deeje LLC. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import os.log
import SwiftUI

class LaunchCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var persistentContainer: NSPersistentContainer

    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }
    
    func start() {
        let carsList = CarsListViewController.instantiate { coder in
            return CarsListViewController(coder: coder, persistentContainer: self.persistentContainer)
        }
        let viewControllers: [UIViewController] = [carsList]
        
        self.navigationController.setViewControllers(viewControllers, animated: false)
    }
    
}
