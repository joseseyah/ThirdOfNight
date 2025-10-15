//
//  BrowseCategory.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 13/10/2025.
//
import Foundation
import SwiftUI

struct BrowseCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
}
