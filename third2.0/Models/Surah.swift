//
//  Surah.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/12/2024.
//

import Foundation

struct Surah: Identifiable {
    let id = UUID()
    let name: String
    let audioFileName: String
    let imageFileName: String
}
