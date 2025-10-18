//
//  LanguageRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct LanguageRow: View {
    @AppStorage("appLanguage") private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    private var displayName: String {
        LanguagePickerSheet.supported.first(where: { $0.code == appLanguage })?.name
        ?? Locale.current.localizedString(forLanguageCode: appLanguage)?.capitalized
        ?? "System"
    }

    var body: some View {
        Row(icon: "globe", title: "App language", trailing: {
            Text(displayName)
                .foregroundStyle(Color.textSecondary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
        })
    }
}
