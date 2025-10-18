//
//  LegalRows.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct LegalRows: View {
    // Replace with your real URLs
    private let privacyURL = URL(string: "https://example.com/privacy")!
    private let termsURL   = URL(string: "https://example.com/terms")!

    var body: some View {
        VStack(spacing: 0) {
            LinkRow(icon: "lock.shield", title: "Privacy Policy", url: privacyURL)
            Divider().overlay(Color.stroke)
            LinkRow(icon: "doc.plaintext", title: "Terms & Conditions", url: termsURL)
        }
    }
}
