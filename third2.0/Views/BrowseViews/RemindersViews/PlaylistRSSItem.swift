//
//  PlaylistRSSItem.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 13/10/2025.
//


import Foundation

struct PlaylistRSSItem: Hashable {
    let videoId: String
    let title: String
    let channel: String
}

enum PlaylistRSSParser {
    static func parse(data: Data) throws -> [PlaylistRSSItem] {
        let delegate = Delegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw parser.parserError ?? NSError(domain: "PlaylistRSSParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse feed"])
        }
        return delegate.items
    }

    // MARK: - XML Delegate
    private final class Delegate: NSObject, XMLParserDelegate {
        var items: [PlaylistRSSItem] = []

        // State
        private var inEntry = false
        private var inAuthor = false
        private var currentTitle = ""
        private var currentVideoId = ""
        private var currentChannel = ""
        private var pendingLinkHref: String?

        private var buffer = ""

        func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            let local = name.lowercased()
            if local == "entry" {
                inEntry = true
                currentTitle = ""
                currentVideoId = ""
                currentChannel = ""
                pendingLinkHref = nil
            } else if inEntry && local == "author" {
                inAuthor = true
            } else if inEntry && local == "link" {
                // <link rel="alternate" href="https://www.youtube.com/watch?v=VIDEOID">
                if let href = attributeDict["href"] {
                    pendingLinkHref = href
                }
            }
            buffer = ""
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            buffer.append(string)
        }

        func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName qName: String?) {
            let local = name.lowercased()
            let text = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

            if inEntry {
                switch local {
                case "title":
                    if !inAuthor { currentTitle = text }
                case "yt:videoid", "videoid":
                    // YouTube uses <yt:videoId>
                    if !text.isEmpty { currentVideoId = text }
                case "name":
                    if inAuthor { currentChannel = text }
                case "author":
                    inAuthor = false
                case "entry":
                    // Fallback: derive videoId from link if <yt:videoId> missing
                    if currentVideoId.isEmpty, let href = pendingLinkHref, let id = Self.extractVideoID(from: href) {
                        currentVideoId = id
                    }
                    if !currentTitle.isEmpty, !currentVideoId.isEmpty {
                        items.append(PlaylistRSSItem(videoId: currentVideoId, title: currentTitle, channel: currentChannel))
                    }
                    inEntry = false
                default:
                    break
                }
            }

            buffer = ""
        }

        // Robust extraction: https://www.youtube.com/watch?v=ID or youtu.be/ID
        private static func extractVideoID(from urlString: String) -> String? {
            if let comps = URLComponents(string: urlString),
               let v = comps.queryItems?.first(where: { $0.name == "v" })?.value,
               !v.isEmpty {
                return v
            }
            // youtu.be/ID
            if let url = URL(string: urlString) {
                let parts = url.path.split(separator: "/")
                if url.host?.contains("youtu.be") == true, let last = parts.last {
                    return String(last)
                }
            }
            return nil
        }
    }
}
