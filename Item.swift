//
//  Item.swift
//  third
//
//  Created by Joseph Hayes on 29/03/2024.
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
