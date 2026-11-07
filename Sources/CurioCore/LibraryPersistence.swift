import Foundation

public enum LibraryPersistence {
    public static func load(from url: URL) throws -> LibrarySnapshot {
        guard FileManager.default.fileExists(atPath: url.path) else { return LibrarySnapshot() }
        return try JSONDecoder().decode(LibrarySnapshot.self, from: Data(contentsOf: url))
    }

    public static func save(_ snapshot: LibrarySnapshot, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(snapshot).write(to: url, options: .atomic)
    }
}
