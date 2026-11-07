import CurioCore
import SwiftUI

/// Public feeds are small. Eager cells let tvOS focus reach uploads below the
/// non-lazy channel header even when the first upload begins off screen.
struct ChannelUploadsGrid: View {
    let videos: [Video]

    private var rows: [UploadRow] {
        stride(from: 0, to: videos.count, by: 4).map { start in
            UploadRow(id: videos[start].id, videos: Array(videos[start..<min(start + 4, videos.count)]))
        }
    }

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 36, verticalSpacing: 36) {
            ForEach(rows) { row in
                GridRow {
                    ForEach(row.videos) { video in VideoCard(video: video, identifierPrefix: "upload") }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .focusSection()
    }
}

private struct UploadRow: Identifiable {
    let id: String
    let videos: [Video]
}
