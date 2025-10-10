//
//  BottomRoundedMask.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 09/10/2025.
//


import SwiftUI
import UIKit

struct BottomRoundedMask: Shape {
    var radius: CGFloat = 26
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(p.cgPath)
    }
}
