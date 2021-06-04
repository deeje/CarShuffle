//
//  Car+CloudCoreSharing.swift
//  CarShuffle
//
//  Created by deeje cooley on 6/4/21.
//

import CoreData
import CloudKit
import UIKit
import CloudCore

extension Car: CloudCoreSharing {
    
    public var sharingTitle: String? {
        return name
    }
    
    public var sharingType: String? {
        return "com.deeje.CarShuffle.car"
    }
    
    public var sharingImage: Data? {
        return nil
    }
    
    public var recordName: String? {
        return uuid
    }
    
    public var ownerName: String? {
        return ownerUUID
    }
        
}
