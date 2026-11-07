import CurioCore
import SwiftUI

struct HeroView: View {
    let channel: Channel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ThumbnailView(url: channel.featuredVideo?.thumbnailURL, title: channel.name)
                        .frame(width: geometry.size.width * 0.66, height: 430)
                        .clipped()
                }
                LinearGradient(stops: [
                    .init(color: Palette.surface, location: 0.25),
                    .init(color: Palette.surface.opacity(0.9), location: 0.43),
                    .init(color: Palette.surface.opacity(0.12), location: 0.78)
                ], startPoint: .leading, endPoint: .trailing)
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 14) {
                        TierBadge(tier: channel.tier)
                        Text("THE CURIOSITY COLLECTION").font(.caption2.weight(.semibold)).tracking(3)
                    }
                    Text("Stay curious.")
                        .font(.largeTitle.weight(.bold))
                        .tracking(-2)
                    Text("Remarkable makers. Beautiful science.")
                        .font(.body).foregroundStyle(Palette.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 24) {
                        if let video = channel.featuredVideo {
                            NavigationLink(value: video) {
                                Label("Explore the pick", systemImage: "play.fill")
                            }
                            .buttonStyle(ActionButtonStyle(prominent: true))
                            .accessibilityIdentifier("hero.pick")
                        }
                        NavigationLink("Browse channel", value: channel)
                            .buttonStyle(ActionButtonStyle())
                            .accessibilityIdentifier("hero.channel")
                    }
                    .padding(.top, 6)
                    Text("FEATURING  \(channel.name.uppercased())")
                        .font(.caption2).tracking(2).foregroundStyle(Palette.secondary)
                }
                .padding(44)
            }
            .clipShape(.rect(cornerRadius: 22))
            .overlay { RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.08)) }
        }
        .frame(height: 430)
        .focusSection()
    }
}
