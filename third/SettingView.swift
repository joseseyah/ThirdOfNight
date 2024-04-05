//
//  SettingView.swift
//  third
//
//  Created by Joseph Hayes on 05/04/2024.
//

import Foundation

import SwiftUI

struct SettingView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
                .padding(.bottom, 20)
            
            Toggle(isOn: $isDarkMode) {
                Text("Dark Mode")
            }
            .padding(.bottom, 20)
            
            // Add your other settings content here
            
            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

