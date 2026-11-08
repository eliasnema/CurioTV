import Foundation

public struct CurationSnapshot: Codable, Equatable, Sendable {
    public private(set) var collections: [ChannelCollection] = []
    public private(set) var selectedCollectionID: UUID?

    public init() {}

    private enum CodingKeys: CodingKey { case collections, selectedCollectionID }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        collections = try values.decode([ChannelCollection].self, forKey: .collections)
        selectedCollectionID = try values.decodeIfPresent(UUID.self, forKey: .selectedCollectionID)
        guard Set(collections.map(\.id)).count == collections.count else { throw CurationError.invalidData }
        for collection in collections { try collection.validate() }
        guard selectedCollectionID == nil || collections.contains(where: { $0.id == selectedCollectionID }) else {
            throw CurationError.invalidData
        }
    }

    @discardableResult
    public mutating func create(name: String, channels: [Channel] = []) throws -> UUID {
        try checkName(name)
        let collection = try ChannelCollection(name: name, channels: channels)
        collections.append(collection)
        return collection.id
    }

    public mutating func select(_ id: UUID?) throws {
        guard id == nil || collections.contains(where: { $0.id == id }) else { throw CurationError.collectionMissing }
        selectedCollectionID = id
    }

    @discardableResult
    public mutating func duplicate(_ id: UUID, name: String) throws -> UUID {
        try checkName(name)
        guard let source = collections.first(where: { $0.id == id }) else { throw CurationError.collectionMissing }
        let copy = try source.copy(named: name)
        collections.append(copy)
        return copy.id
    }

    public mutating func rename(_ id: UUID, to name: String) throws {
        try checkName(name, excluding: id)
        try update(id) { try $0.rename(name) }
    }

    public mutating func update(_ id: UUID, _ change: (inout ChannelCollection) throws -> Void) throws {
        guard let index = collections.firstIndex(where: { $0.id == id }) else { throw CurationError.collectionMissing }
        var updated = collections[index]
        try change(&updated)
        try updated.validate()
        collections[index] = updated
    }

    public mutating func delete(_ id: UUID) {
        collections.removeAll { $0.id == id }
        if selectedCollectionID == id { selectedCollectionID = nil }
    }

    private func checkName(_ name: String, excluding id: UUID? = nil) throws {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !collections.contains(where: { $0.id != id && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) else {
            throw CurationError.duplicateName
        }
    }
}
