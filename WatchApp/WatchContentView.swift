//
//  WatchContentView.swift
//  Night Prayers Watch App
//
//  Main content view for Watch app
//

import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var watchConnectivity: WatchConnectivityManagerWatch
    @State private var isConnected = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("Night Prayers")
                .font(.headline)
            
            if isConnected {
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("Waiting for iPhone")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            isConnected = watchConnectivity.isPhoneConnected
            // Start prayer detection when view appears
            watchConnectivity.prayerDetectionModel?.startDetection()
        }
        .onDisappear {
            // Stop prayer detection when view disappears
            watchConnectivity.prayerDetectionModel?.stopDetection()
        }
        .onChange(of: watchConnectivity.isPhoneConnected) { _, newValue in
            isConnected = newValue
        }
    }
}

