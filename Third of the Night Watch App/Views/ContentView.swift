//
//  ContentView.swift
//  Third of the Night Watch App
//
//  Created by Joseph Hanson Villar Hayes on 15/12/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var watchConnectivity: WatchConnectivityManagerWatch
    @State private var isConnected = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Night Prayers")
                .font(.headline)
            
            Text("Prayer Detection Active")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isConnected {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Connected to iPhone")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Connecting...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Text("Detection runs in the background")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .onAppear {
            isConnected = watchConnectivity.isPhoneConnected
            // Detection is already started in App init, but ensure it's running
            watchConnectivity.startBackgroundDetection()
        }
        .onChange(of: watchConnectivity.isPhoneConnected) { _, newValue in
            isConnected = newValue
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManagerWatch.shared)
}
