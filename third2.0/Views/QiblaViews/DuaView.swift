//
//  DuaView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import SwiftUI


struct DuaView: View {
    let title: String
    let arabic: String
    let translation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("HighlightColor"))

            Text(arabic)
                .font(.body)
                .foregroundColor(Color("HighlightColor"))

            Text(translation)
                .font(.footnote)
                .italic()
                .foregroundColor(Color("HighlightColor"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("BoxBackgroundColor"))
        )
    }
}
