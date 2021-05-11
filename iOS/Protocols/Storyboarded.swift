//
//  Storyboarded.swift
//  WTSDA
//
//  Created by deeje cooley on 10/28/19.
//  Copyright © 2019 deeje LLC. All rights reserved.
//

import UIKit

protocol Storyboarded {
    
    static func storyboardName() -> String
    static func storyboardIdentifier() -> String
    static func instantiate(creator: ((NSCoder) -> UIViewController?)?) -> Self
    
}

extension Storyboarded where Self: UIViewController {
    
    static func storyboardName() -> String {
        return "Main"
    }
    
    static func storyboardIdentifier() -> String {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".").last!
        return className
    }
    
    static func instantiate(creator: ((NSCoder) -> UIViewController?)? = nil) -> Self {
        let bundleName = self.storyboardName()
        let storyboard = UIStoryboard(name: bundleName, bundle: Bundle.main)
        
        let identifier = self.storyboardIdentifier()
        // swiftlint:disable:next force_cast
        return storyboard.instantiateViewController(identifier: identifier, creator: creator) as! Self
    }
    
}
