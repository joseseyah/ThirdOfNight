//
//  ReminderItem.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import Foundation

struct Playlist: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let blurb: String
    let youtubePlaylistURL: URL
    /// Provide up to 4 video IDs from the playlist for the mosaic thumbnails
    let previewVideoIDs: [String]

    var thumbnailURLs: [URL] {
        previewVideoIDs.prefix(4).compactMap { URL(string: "https://img.youtube.com/vi/\($0)/hqdefault.jpg") }
    }
}
