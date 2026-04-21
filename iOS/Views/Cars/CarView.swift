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
    
    var car: Car
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "car")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(car.name!)
                if let reminder = car.reminder, let moveBy = reminder.moveBy, let localMoveBy = moveBy.inLocalTime() {
                    Text(localMoveBy.toString(DateToStringStyles.dateTime(.short)))
                }
            }
        }

    }
    
}
