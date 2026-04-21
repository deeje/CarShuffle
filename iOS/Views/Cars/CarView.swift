//
//  CarView.swift
//  CarShuffle
//
//  Created by deeje on 2026-04-21.
//

import SwiftUI
import CoreData
import SwiftDate

extension Date {
    func inLocalTime() -> Date? {
        return Calendar.current.date(byAdding: .second,
                                     value: TimeZone.current.secondsFromGMT(),
                                     to: self)
    }
}

struct CarView: View {
    
    @ObservedObject var car: Car
    
    var body: some View {
        if let reminder = car.reminder, let moveBy = reminder.moveBy {
            TimelineView(.periodic(from: .now, by: updateInterval(for: moveBy))) { context in
                let now = context.date.inLocalTime()!
                let state = Countdown.state(for: moveBy, now: now)
                cardContent(state: state, moveBy: moveBy, now: now)
            }
        } else {
            cardContent(state: nil, moveBy: nil, now: Date())
        }
    }
    
    @ViewBuilder
    private func cardContent(state: Countdown?, moveBy: Date?, now: Date) -> some View {
        HStack(spacing: 12) {
            countdownIcon(state: state, moveBy: moveBy, now: now)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(car.name ?? "unnamed")
                    .font(.headline)
                
                if let moveBy {
                    if let localMoveBy = moveBy.inLocalTime() {
                        Text(localMoveBy.toString(DateToStringStyles.dateTime(.short)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let state {
                        Text(timeRemainingText(state: state, moveBy: moveBy, now: now))
                            .font(.subheadline)
                            .foregroundStyle(state.color)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func countdownIcon(state: Countdown?, moveBy: Date?, now: Date) -> some View {
        let color = state?.color ?? .secondary
        let progress: Double = {
            guard let state, let moveBy, state != .expired else { return 0 }
            let total = Countdown.ok.timeInterval()
            let remaining = moveBy.timeIntervalSince(now)
            return max(0, min(1, remaining / total))
        }()
        
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: iconName(for: state))
                .font(.title2)
                .foregroundStyle(color)
        }
    }
    
    private func iconName(for state: Countdown?) -> String {
        switch state {
        case .ok:
            return "car.fill"
        case .caution:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "exclamationmark.octagon.fill"
        case .expired:
            return "xmark.octagon.fill"
        case nil:
            return "car"
        }
    }
    
    private func timeRemainingText(state: Countdown, moveBy: Date, now: Date) -> String {
        let remaining = moveBy.inLocalTime()!.timeIntervalSince(now)
        
        if state == .expired {
            return "Expired"
        }
        
        let days = Int(remaining) / 86400
        let hours = Int(remaining) / 3600
        let minutes = Int(remaining) / 60
        
        if days > 0 {
            return "\(days)d"
        } else if hours > 1 {
            return "\(hours)h remaining"
        } else if hours == 0 && minutes > 1 {
            return "\(minutes)m remaining"
        } else {
            return "Expiring"
        }
    }
    
    private func updateInterval(for moveBy: Date) -> TimeInterval {
        let state = Countdown.state(for: moveBy)
        return state.updateInterval
    }
    
}
