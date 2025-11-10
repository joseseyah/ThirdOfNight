//
//  TravelRowItem.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import Foundation

public struct TravelRowItem {
    public let display: PrayerDisplay
    public let isDone: Bool
    public let isEnabled: Bool
    public let onTap: () -> Void

    public init(display: PrayerDisplay, isDone: Bool, isEnabled: Bool, onTap: @escaping () -> Void) {
        self.display = display
        self.isDone = isDone
        self.isEnabled = isEnabled
        self.onTap = onTap
    }
}
