import Foundation

public struct ChannelCollection: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public private(set) var name: String
    public private(set) var channels: [Channel]
    private var limits: [String: Int]

    public init(id: UUID = UUID(), name: String, channels: [Channel] = []) throws {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.channels = channels
        limits = [:]
        try validate()
    }

    public func limit(for tier: Tier) -> Int? { limits[tier.rawValue] }
    public func count(in tier: Tier) -> Int { channels.filter { $0.tier == tier }.count }

    public func copy(named name: String) throws -> ChannelCollection {
        var copy = try ChannelCollection(name: name, channels: channels)
        copy.limits = limits
        return copy
    }

    public mutating func rename(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 60 else { throw CurationError.invalidName }
        self.name = trimmed
    }

    public mutating func setLimit(_ limit: Int?, for tier: Tier) throws {
        if let limit {
            guard limit > 0 else { throw CurationError.invalidLimit }
            let count = count(in: tier)
            guard count <= limit else { throw CurationError.tierFull(tier, limit: limit, requested: count) }
        }
        limits[tier.rawValue] = limit
    }

    public mutating func add(_ incoming: [Channel], tier: Tier? = nil) throws {
        var proposed = channels
        for channel in incoming {
            let channel = tier.map(channel.ranked) ?? channel
            if let index = proposed.firstIndex(where: { $0.id == channel.id || $0.url == channel.url }) {
                proposed[index] = channel
            } else { proposed.append(channel) }
        }
        var updated = self
        updated.channels = proposed
        try updated.validate()
        self = updated
    }

    public mutating func move(_ ids: Set<String>, to tier: Tier) throws {
        let proposed = channels.map { ids.contains($0.id) ? $0.ranked(tier) : $0 }
        try checkLimits(proposed)
        channels = proposed
    }

    public mutating func remove(_ ids: Set<String>) { channels.removeAll { ids.contains($0.id) } }

    public func validate() throws {
        guard !name.isEmpty, name.count <= 60 else { throw CurationError.invalidName }
        guard Set(channels.map(\.id)).count == channels.count,
              limits.allSatisfy({ Tier(rawValue: $0.key) != nil && $0.value > 0 }) else { throw CurationError.invalidData }
        for channel in channels {
            guard !channel.name.isEmpty, channel.name.count <= 100,
                  (try? ChannelAddress(channel.url.absoluteString)) != nil else { throw CurationError.invalidData }
        }
        try checkLimits(channels)
    }

    private func checkLimits(_ channels: [Channel]) throws {
        for tier in Tier.allCases {
            if let limit = limit(for: tier) {
                let count = channels.filter { $0.tier == tier }.count
                guard count <= limit else { throw CurationError.tierFull(tier, limit: limit, requested: count) }
            }
        }
    }
}
