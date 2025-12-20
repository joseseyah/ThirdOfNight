//
//  TimePickerRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct TimePickerRow: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentPurple.opacity(0.15))
                    .frame(width: 60, height: 34)
                Image(systemName: "clock")
                    .foregroundStyle(Color.accentPurple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(Color.textPrimary)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(date.formatted(date: .omitted, time: .shortened))
                    .foregroundStyle(Color.textSecondary)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
            }

            Spacer()

            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(.accentPurple)
        }
        .padding(.vertical, 8)
    }
}
