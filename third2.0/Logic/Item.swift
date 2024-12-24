//
//  Item.swift
//  third2.0
//
//  Created by Joseph Hayes on 06/10/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
