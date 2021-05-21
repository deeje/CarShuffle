//
//  Countdown.swift
//  CarShuffle
//
//  Created by deeje cooley on 5/18/21.
//

import UIKit
import SwiftDate

enum Countdown: String, CaseIterable {
    case ok
    case caution
    case danger
    case expired
    
    func color() -> UIColor {
        switch self {
        case .ok:
            return .systemGreen
        case .caution:
            return .systemYellow
        case .danger:
            return .systemRed
        case .expired:
            return .systemRed
        }
    }
    
    func dateComponents() -> DateComponents {
        switch self {
        case .ok:
            return 24.hours
        case .caution:
            return 12.hours
        case .danger:
            return 1.hours
        case .expired:
            return 0.minutes
        }
    }
    
    func timeInterval() -> TimeInterval {
        return dateComponents().timeInterval
    }
    
}
