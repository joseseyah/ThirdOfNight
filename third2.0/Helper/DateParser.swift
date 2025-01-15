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
    static func convertToHijri(from gregorianDate: String) -> String? {
        // Define the input format
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstant.appReadableDateFormatter
        formatter.calendar = Calendar(identifier: .gregorian)
        
        // Convert string to Date
        guard let date = formatter.date(from: gregorianDate) else {
            print("Invalid Gregorian date format.")
            return gregorianDate
        }
        
        // Define the Hijri calendar
        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        
        // Convert to Hijri date components
        let hijriComponents = hijriCalendar.dateComponents([.year, .month, .day], from: date)
        
        // Format the Hijri date
        let hijriFormatter = DateFormatter()
        hijriFormatter.calendar = hijriCalendar
        hijriFormatter.dateFormat = "d MMMM yyyy" // Customize as needed (e.g., "dd MMM yyyy")
        
        // Create a new Hijri Date
        guard let hijriDate = hijriCalendar.date(from: hijriComponents) else {
            print("Failed to convert to Hijri date.")
            return gregorianDate
        }
        
        return hijriFormatter.string(from: hijriDate)
    }
    static func strDateToReadDate(dateString: String) -> String? {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = AppConstant.appReadableDateFormatter
            
            if let date = inputFormatter.date(from: dateString) {
                return outputFormatter.string(from: date)
            } else {
                return dateString
            }
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
