import Foundation
import SwiftUI
import AVKit
import PDFKit

struct QuranView: View {
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel // Receive ViewModel
    @State private var searchText = ""
    @State private var selectedMode: Mode = .listen // Default to "Listen" mode
    @State private var selectedBook: Book? = nil // Track selected book
    @State private var preloadedPDFs: [String: PDFDocument] = [:] // Cache preloaded PDFs

    enum Mode: String, CaseIterable, Identifiable {
        case listen = "Listen"
        case read = "Read"

        var id: String { rawValue }
    }

    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        } else {
            return surahs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    let books: [Book] = [
        Book(title: "Quran", coverImage: "big-quran-cover", pdfFileName: "big-quran")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Mode Picker
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(Mode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.horizontal, .top])

                    // Content Based on Selected Mode
                    if selectedMode == .listen {
                        listenModeContent
                    } else {
                        readModeContent
                    }
                }
                .navigationTitle("Quran")
                .foregroundColor(.white)
                .onAppear {
                    preloadPDFs()
                }
            }
        }
    }

    private var listenModeContent: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("HighlightColor"))
                TextField("Search Surah...", text: $searchText)
                    .foregroundColor(Color("HighlightColor"))
                    .placeholder(when: searchText.isEmpty) {
                        Text("Search Surah...")
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
            }
            .padding(10)
            .background(Color("BoxBackgroundColor"))
            .cornerRadius(8)
            .padding([.horizontal, .top])

            // Surah List
            List(filteredSurahs) { surah in
                Button(action: {
                    playSurah(surah)
                }) {
                    HStack {
                        Image(surah.imageFileName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        Text(surah.name)
                            .font(.headline)
                            .foregroundColor(Color("HighlightColor"))
                    }
                    .padding()
                    .background(Color("BoxBackgroundColor")) // Box Background
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear) // Transparent row background
            }
            .scrollContentBackground(.hidden) // Hide default List background
            .background(Color("BackgroundColor")) // Ensure consistent background
        }
    }

    private var readModeContent: some View {
        VStack {
            Text("Coming Soon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("HighlightColor"))
                .padding()
            Text("The Read feature is under development. Please check back later!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(12)
        .padding()
    }


    private func playSurah(_ surah: Surah) {
        if let index = surahs.firstIndex(where: { $0.id == surah.id }) {
            audioPlayerViewModel.currentTrackIndex = index
            audioPlayerViewModel.isMinimizedViewVisible = true

            if let path = Bundle.main.path(forResource: surah.audioFileName, ofType: "mp3") {
                do {
                    audioPlayerViewModel.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayerViewModel.audioPlayer?.play()
                    audioPlayerViewModel.isPlaying = true
                } catch {
                    print("Error: Could not play audio file. \(error.localizedDescription)")
                }
            } else {
                print("Error: Audio file not found.")
            }
        }
    }

    private func preloadPDFs() {
        for book in books {
            if let path = Bundle.main.path(forResource: book.pdfFileName, ofType: "pdf"),
               let document = PDFDocument(url: URL(fileURLWithPath: path)) {
                preloadedPDFs[book.pdfFileName] = document
            }
        }
    }
}

struct FullScreenPDFView: View {
    let preloadedPDF: PDFDocument
    let bookTitle: String

    var body: some View {
        PDFKitRepresentable(preloadedPDF: preloadedPDF)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle(bookTitle, displayMode: .inline)
    }
}

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

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let coverImage: String
    let pdfFileName: String
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}

