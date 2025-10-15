import SwiftUI

// MARK: - Lightweight model for playlist videos (separate from your ReminderItem)
struct PlaylistVideo: Identifiable, Hashable {
    let id: String          // YouTube videoId
    let title: String
    let channel: String
    let url: URL
    var thumbnailURL: URL? { URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg") }
}

// MARK: - View

struct RemindersView: View {
    let category: BrowseCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    // Playlists are now derived from the category, we load videos into here:
    @State private var videos: [PlaylistVideo] = []
    @State private var isLoading = true
    @State private var loadError: String?

    // Map each category title to its playlist ID
    private var playlistID: String? {
        switch category.title {
        case "Fajr Reflections", "Fajr Reminders":
            return "PLSFZjjKC3qPbs_sWVYbJQ9tfaXcXwSbfC" // your provided playlist
        case "Jummah":
            return "YOUR_JUMMAH_LIST_ID"
        case "Quran Series":
            return "YOUR_QURAN_LIST_ID"
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    // Header
                    HStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.accentYellow)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Title from the tab/category
                    Text(category.title) // e.g. "Fajr Reflections"
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .fontWidth(.condensed) // iOS 17+
                        .tracking(-0.2)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                    // Status / error
                    Group {
                        if isLoading {
                            VStack(spacing: 10) {
                                ProgressView()
                                Text("Loading videos…")
                                    .font(.system(size: 15, weight: .regular, design: .default))
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else if let loadError {
                            VStack(spacing: 10) {
                                Text(loadError)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 15))
                                    .foregroundColor(.textSecondary)
                                Button("Retry") {
                                    Task { await loadPlaylist() }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                        }
                    }

                    // Video list
                    LazyVStack(spacing: 16) { // spacing instead of dividers (clean, modern)
                        ForEach(videos) { v in
                            Button {
                                openURL(v.url)
                            } label: {
                                VideoRowModern(video: v)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }




                    .padding(.bottom, 28)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadPlaylist()
        }
    }

    // MARK: - Data load

    private func loadPlaylist() async {
        guard let playlistID else {
            isLoading = false
            loadError = "No playlist is configured for “\(category.title)”."
            return
        }

        isLoading = true
        loadError = nil

        do {
            let feedURL = URL(string: "https://www.youtube.com/feeds/videos.xml?playlist_id=\(playlistID)")!
            let (data, response) = try await URLSession.shared.data(from: feedURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let parsed = try PlaylistRSSParser.parse(data: data)
            // Convert RSS items to our PlaylistVideo
            let vids: [PlaylistVideo] = parsed.map {
                PlaylistVideo(
                    id: $0.videoId,
                    title: $0.title,
                    channel: $0.channel,
                    url: URL(string: "https://www.youtube.com/watch?v=\($0.videoId)")!
                )
            }
            await MainActor.run {
                self.videos = vids
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.loadError = "Couldn’t load videos right now."
            }
        }
    }
}

// MARK: - Video Row (Apple-like)

import SwiftUI

struct VideoRow: View {
    let video: PlaylistVideo
    var showDivider: Bool = true   // set false for the last row

    // Apple Tips–like proportions
    private let thumbWidth: CGFloat = 88      // ~3:4 aspect
    private let thumbHeight: CGFloat = 118
    private let corner: CGFloat = 18

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {

                // Thumbnail (large, soft corners)
                AsyncImage(url: video.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .empty: ZStack { Color.cardBg.opacity(0.6); ProgressView().scaleEffect(0.8) }
                    case .failure(_):
                        ZStack {
                            Color.cardBg
                            Image(systemName: "photo")
                                .font(.system(size: 20, weight: .medium))
                                .opacity(0.35)
                        }
                    @unknown default: Color.cardBg
                    }
                }
                .frame(width: thumbWidth, height: thumbHeight)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

                // Text block (title + grey subline)
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .tracking(-0.2)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(video.channel)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                .layoutPriority(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.75))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle()) // full-row tap target

            // Inset divider (aligned under text, not thumbnail)
            if showDivider {
                Divider()
                    .overlay(Color.white.opacity(0.08))
                    .padding(.leading, 16 + thumbWidth + 16) // left padding + image + gap
            }
        }
        .background(Color.clear) // flat list look
    }
}
