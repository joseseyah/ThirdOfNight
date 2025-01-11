//
//  PDFKitRepresentable.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/01/2025.
//

import Foundation
import PDFKit
import SwiftUI

struct PDFKitRepresentable: UIViewRepresentable {
    let preloadedPDF: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.document = preloadedPDF
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
