////
////  QuranBookshelfView.swift
////  Night Prayers
////
////  Created by Joseph Hayes on 19/12/2024.
////
//
//import Foundation
//import SwiftUI
//import PDFKit
//
//struct QuranBookshelfView: View {
//    @State private var selectedBook: Book? = nil // Track selected book
//    @State private var isBookOpened = false // To open PDF on tap
//    
//    let books: [Book] = [
//        Book(title: "Quran", coverImage: "big-quran-cover", pdfFileName: "big-quran")
//    ]
//    
//    let columns = [
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//        GridItem(.flexible())
//    ]
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background Color
//                Color("BackgroundColor")
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    // Bookshelf Title
//                    Text("Bookshelf")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(Color("HighlightColor"))
//                        .padding(.top)
//                    
//                    // Bookshelf Grid
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            ForEach(books) { book in
//                                VStack {
//                                    Button(action: {
//                                        selectedBook = book
//                                        isBookOpened = true
//                                    }) {
//                                        Image(book.coverImage)
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 100, height: 150)
//                                            .cornerRadius(8)
//                                            .shadow(radius: 4)
//                                    }
//                                    Text(book.title)
//                                        .font(.headline)
//                                        .foregroundColor(Color("HighlightColor"))
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                }
//                .navigationTitle("Bookshelf")
//                .sheet(isPresented: $isBookOpened) {
//                    if let selectedBook = selectedBook {
//                        PDFReaderView(pdfName: selectedBook.pdfFileName)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct PDFReaderView: UIViewRepresentable {
//    let pdfName: String
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.displayDirection = .horizontal
//        pdfView.usePageViewController(true)
//        
//        if let path = Bundle.main.path(forResource: pdfName, ofType: "pdf"),
//           let document = PDFDocument(url: URL(fileURLWithPath: path)) {
//            pdfView.document = document
//        } else {
//            print("Error: PDF file not found.")
//        }
//        
//        return pdfView
//    }
//    
//    func updateUIView(_ uiView: PDFView, context: Context) {
//        // No updates required for now
//    }
//}
//
//struct Book: Identifiable {
//    let id = UUID()
//    let title: String
//    let coverImage: String
//    let pdfFileName: String
//}
