//
//  Coordinator.swift
//  WTSDA
//
//  Created by deeje cooley on 10/28/19.
//  Copyright © 2019 deeje LLC. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get set }
    
    func start()
    
}
