//
//  DateExtension.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}
