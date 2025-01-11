//
//  Book.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/01/2025.
//

import Foundation

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let coverImage: String
    let pdfFileName: String
}
