//
//  SettingsButton.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 20/12/2024.
//

import Foundation
import SwiftUI

struct SettingsButton: View {
    var title: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
