//
//  TrackerPrayer.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//
import Foundation

struct TrackerPrayer: Identifiable {
    let id = UUID()
    let name: String
    let timeLabel: String
    let start: Date
    let nextStart: Date
    var done: Bool

    func canMark(at now: Date = Date()) -> Bool {
        now >= start && now < nextStart
    }
}
