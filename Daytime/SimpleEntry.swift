//
//  SimpleEntry.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 01/12/2024.
//

import Foundation

struct SimpleEntry: TimelineEntry {
    let date: Date
    let prayers: [Prayer]
}

struct Prayer {
    let name: String
    let time: String
}

// Static prayer times
let staticPrayerTimes: [Prayer] = [
    Prayer(name: "Fajr", time: "6:15 AM"),
    Prayer(name: "Dhuhr", time: "1:10 PM"),
    Prayer(name: "Asr", time: "3:45 PM"),
    Prayer(name: "Maghrib", time: "5:00 PM"),
    Prayer(name: "Isha", time: "7:00 PM")
]
