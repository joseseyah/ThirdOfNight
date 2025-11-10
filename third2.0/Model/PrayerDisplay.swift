//
//  PrayerDisplay.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import Foundation

public struct PrayerDisplay: Equatable {
    public let name: String
    public let timeText: String
    public init(name: String, timeText: String) {
        self.name = name
        self.timeText = timeText
    }
}
