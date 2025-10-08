//
//  ReminderItem.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import Foundation

struct ReminderItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String
    var url: URL?
}
