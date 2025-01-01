import SwiftUI
import PDFKit

struct SurahMulkView: View {
    @State private var selectedLanguage = 0 // 0 for Arabic, 1 for English

    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header with title
                VStack {
                    Text("Surah Mulk")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("HighlightColor"))
                    
                    Text("Chapter 67 of the Quran")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 30)

                // Language selector
                Picker("", selection: $selectedLanguage) {
                    Text("Arabic").tag(0)
                    Text("English").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color("BoxBackgroundColor"))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)

                // Full PDF Display
                Group {
                    if selectedLanguage == 0 {
                        PDFViewer(pdfName: "67-surah-al-mulk") // Arabic PDF
                    } else {
                        PDFViewer(pdfName: "surah-al-mulk_word-to-word-translation") // English PDF
                    }
                }
                .padding(.horizontal)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                Spacer()
            }
        }
    }
}

// PDF Viewer Component
struct PDFViewer: View {
    let pdfName: String

    var body: some View {
        if let url = getPDFUrl(for: pdfName), let pdfDocument = PDFDocument(url: url) {
            PDFKitRepresentedView(pdfDocument: pdfDocument)
                .cornerRadius(15)
        } else {
            Text("PDF Not Found")
                .font(.headline)
                .foregroundColor(.red)
                .padding()
        }
    }

    // Helper function to get PDF URL
    private func getPDFUrl(for name: String) -> URL? {
        guard let path = Bundle.main.path(forResource: name, ofType: "pdf") else {
            print("PDF file not found: \(name)")
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}

// PDFKit Represented View
struct PDFKitRepresentedView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous // Enables scrolling across pages
        pdfView.displayDirection = .horizontal // Enables horizontal scrolling
        pdfView.backgroundColor = .clear
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// Preview
struct SurahMulkView_Previews: PreviewProvider {
    static var previews: some View {
        SurahMulkView()
            .preferredColorScheme(.dark) // Matches the app theme
    }
}
