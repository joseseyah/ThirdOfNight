//
//  ChipData.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/10/2025.
//
import Foundation

struct ChipData: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let icon: String
        var subtitle: String? = nil
    }
