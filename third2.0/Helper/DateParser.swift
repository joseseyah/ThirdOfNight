//
//  DateParser.swift
//  Night Prayers
//
//  Created by Waqar on 12/01/2025.
//

import Foundation
class DateParser{
    static func getCurrentDateToString() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstant.appReadableDateFormatter
        return formatter.string(from: Date())
    }
    static func convertToYYYYMMDD(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy" // Input format (e.g., "01 Dec 2024")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = AppConstant.appReadableDateFormatter // Desired output format

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            print("Failed to convert date: \(dateString)")
            return dateString // Return the original string if conversion fails
        }
    }
}
