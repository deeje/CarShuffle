//
//  Countdown.swift
//  CarShuffle
//
//  Created by deeje cooley on 5/18/21.
//

import UIKit
import SwiftUI
import SwiftDate

enum Countdown: String, CaseIterable {
    case ok
    case caution
    case danger
    case expired
    
    func uiColor() -> UIColor {
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
    
    var color: Color {
        Color(uiColor())
    }
    
    func relativeHoursRemaining() -> Int {
        switch self {
        case .ok:
            return 24
        case .caution:
            return 12
        case .danger:
            return 1
        case .expired:
            return 0
        }
    }
    
    func dateComponents() -> DateComponents {
        relativeHoursRemaining().hours
    }
    
    func timeInterval() -> TimeInterval {
        return dateComponents().timeInterval
    }
    
    /// Determines the countdown state for a given moveBy date relative to now.
    static func state(for moveBy: Date, now: Date = Date()) -> Countdown {
        let remaining = moveBy.timeIntervalSince(now)
        if remaining <= Countdown.expired.timeInterval() {
            return .expired
        } else if remaining <= Countdown.danger.timeInterval() {
            return .danger
        } else if remaining <= Countdown.caution.timeInterval() {
            return .caution
        } else {
            return .ok
        }
    }
    
    /// The update interval appropriate for this countdown state.
    var updateInterval: TimeInterval {
        switch self {
        case .ok:
            return 60 * 15  // every 15 minutes
        case .caution:
            return 60       // every minute
        case .danger:
            return 1        // every second
        case .expired:
            return 60       // every minute
        }
    }
    
}
