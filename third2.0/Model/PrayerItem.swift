//
//  PrayerItem.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import Foundation

struct PrayerItem: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    var done: Bool = false
}
