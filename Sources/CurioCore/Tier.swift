import Foundation

public enum Tier: String, Codable, CaseIterable, Identifiable, Sendable {
    case s = "S", a = "A", b = "B", c = "C", d = "D"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .s: "The extraordinary"
        case .a: "Expand your horizons"
        case .b: "Keep exploring"
        case .c: "Find a new fascination"
        case .d: "Down the rabbit hole"
        }
    }
}
