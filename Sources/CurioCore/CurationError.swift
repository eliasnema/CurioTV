import Foundation

public enum CurationError: Error, Equatable, LocalizedError {
    case invalidName, duplicateName, collectionMissing, invalidChannelLink, invalidChannelName, invalidData
    case tierFull(Tier, limit: Int, requested: Int)
    case invalidLimit
    case storageLocked, storageFull

    public var errorDescription: String? {
        switch self {
        case .invalidName: "Give the collection a name of 1–60 characters."
        case .duplicateName: "A collection with that name already exists. Choose another name."
        case .collectionMissing: "This collection is no longer available."
        case .invalidChannelLink: "Use a YouTube channel link, @handle, or UC channel ID. Video and playlist links cannot be added as channels."
        case .invalidChannelName: "Give the channel a name of 1–100 characters."
        case .invalidData: "The collection data could not be read safely. The original data has been kept."
        case let .tierFull(tier, limit, requested): "Tier \(tier.rawValue) has a limit of \(limit) channels; this change would contain \(requested). Move channels out or increase the limit first. Nothing was changed."
        case .invalidLimit: "A tier limit must be a positive whole number, or choose No limit."
        case .storageLocked: "The saved collections could not be read. Their data has been kept. Reset the local library in Settings before making changes."
        case .storageFull: "Your local library is full. Remove a few saved videos or channels before adding more. Nothing was changed."
        }
    }
}
