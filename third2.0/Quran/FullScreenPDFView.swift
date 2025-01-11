//
//  FullScreenPDFView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/01/2025.
//

import Foundation
import PDFKit
import SwiftUI

struct FullScreenPDFView: View {
    let preloadedPDF: PDFDocument
    let bookTitle: String

    var body: some View {
        PDFKitRepresentable(preloadedPDF: preloadedPDF)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle(bookTitle, displayMode: .inline)
    }
}
