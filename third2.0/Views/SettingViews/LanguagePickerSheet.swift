//
//  LanguagePickerSheet.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI
import UserNotifications
import Foundation

struct LanguagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    static let supported: [Language] = [
        .init(code: "en", name: "English"),
        .init(code: "ar", name: "العربية"),
        .init(code: "ur", name: "اردو"),
        .init(code: "ms", name: "Bahasa Melayu"),
        .init(code: "fil", name: "Filipino")
    ]

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 14) {
                Capsule()
                    .fill(Color.stroke)
                    .frame(width: 44, height: 5)
                    .padding(.top, 6)

                Text("Choose Language")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 6)

                VStack(spacing: 10) {
                    ForEach(Self.supported) { item in
                        HStack {
                            Text(item.name)
                                .foregroundStyle(Color.textPrimary)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                            Radio(isSelected: selection(for: item))
                        }
                        .padding(14)
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                        .onTapGesture {
                            appLanguage = item.code
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 8)
            }
        }
    }

    private func selection(for item: Language) -> Bool { appLanguage == item.code }
}
