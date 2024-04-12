////
////  sunMovementView.swift
////  third
////
////  Created by Joseph Hayes on 12/04/2024.
////
//
//import Foundation
//
//import SwiftUI
//
//struct SunMovementView: View {
//    @State private var moveAlongPath = 20
//    @State private var scaleX = 0.0
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 400) {
//                HStack {
//                    Text("5:33 AM")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                    
//                    Spacer()
//                    
//                    Text("2:24 PM")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//                
//                Spacer()
//            }
//            .padding()
//        }
//        ZStack{
//            Circle()
//                .trim(from: 1/2, to: 1)
//                .stroke(style: <#T##StrokeStyle#>(lineWidth:1, dash:[7,7]))
//                .frame(width: 300, height:300)
//                .foregroundColor(.yellow)
//            
//            Image(systemName: "sun.max")
//                .font(.title)
//                .foregroundColor(.yellow)
//                .offset(x: -150)
//            
//            ZStack{
//                Rectangle()
//                    .
//            }
//        }
//    }
//}

