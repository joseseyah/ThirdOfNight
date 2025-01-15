import Foundation
import SwiftUI
import AVKit
import PDFKit
import FirebaseStorage

struct QuranView: View {
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel // Receive ViewModel
    @State private var searchText = ""
    @State private var selectedMode: Mode = .listen // Default to "Listen" mode
    @State private var selectedBook: Book? = nil // Track selected book
    @State private var preloadedPDFs: [String: PDFDocument] = [:] // Cache preloaded PDFs
    @State private var isDownloading = false
    @State private var downloadComplete = UserDefaults.standard.bool(forKey: "SurahsDownloaded")
    @State private var downloadProgress = 0.0
    @State private var totalSurahs = Double(surahs.count)

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

//    let books: [Book] = [
//        Book(title: "Quran", coverImage: "big-quran-cover", pdfFileName: "big-quran")
//    ]
//
//    let columns = [
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//        GridItem(.flexible())
//    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if !downloadComplete {
                        if isDownloading {
                            ProgressView("Downloading Surahs...", value: downloadProgress, total: totalSurahs)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                        } else {
                            downloadAllButton
                        }
                    } else {
                        mainContentView
                    }
                }
                .navigationTitle("Quran")
                .foregroundColor(.white)
            }
        }
    }
    
    private var mainContentView: some View {
        VStack {
            Picker("Mode", selection: $selectedMode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .top])

            if selectedMode == .listen {
                listenModeContent
            } else {
                readModeContent
            }
        }
    }
    
    private var downloadAllButton: some View {
        Button("Download All Surahs") {
            downloadAllSurahs()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    private func downloadAllSurahs() {
        isDownloading = true
        downloadProgress = 0
        let group = DispatchGroup()
        
        for (index, surah) in surahs.enumerated() {
            group.enter()
            let storageRef = Storage.storage().reference(withPath: "QuranAudio/\(surah.audioFileName).mp3")
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(surah.audioFileName).mp3")
            
            let downloadTask = storageRef.write(toFile: localURL) { url, error in
                if let error = error {
                    print("Error downloading \(surah.name): \(error)")
                }
                DispatchQueue.main.async {
                    downloadProgress += 1
                }
                group.leave()
            }
            
            downloadTask.observe(.progress) { snapshot in
                print("Progress: \(snapshot.progress!.fractionCompleted)")
            }
        }

        group.notify(queue: .main) {
            isDownloading = false
            UserDefaults.standard.set(true, forKey: "SurahsDownloaded")
            downloadComplete = true
            print("All files downloaded")
        }
    }

    private func checkDownloadsComplete() {
        let allDownloaded = UserDefaults.standard.bool(forKey: "SurahsDownloaded")
        if allDownloaded {
            downloadComplete = true
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

            // Build the URL to the audio file in the document directory
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(surah.audioFileName).mp3")

            do {
                // Try to initialize the AVAudioPlayer with the file URL
                audioPlayerViewModel.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayerViewModel.audioPlayer?.play()
                audioPlayerViewModel.isPlaying = true
            } catch {
                print("Error: Could not play audio file. \(error.localizedDescription)")
            }
        } else {
            print("Error: Surah not found in array.")
        }
    }

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

