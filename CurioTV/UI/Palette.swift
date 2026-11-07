import CurioCore
import SwiftUI

enum Palette {
    static let background = Color(red: 0.035, green: 0.045, blue: 0.064)
    static let surface = Color(red: 0.075, green: 0.090, blue: 0.115)
    static let accent = Color(red: 0.99, green: 0.72, blue: 0.35)
    static let secondary = Color(red: 0.70, green: 0.74, blue: 0.80)

    static func tier(_ tier: Tier) -> Color {
        switch tier {
        case .s: accent
        case .a: Color(red: 0.57, green: 0.83, blue: 0.73)
        case .b: Color(red: 0.55, green: 0.72, blue: 0.94)
        case .c: Color(red: 0.75, green: 0.65, blue: 0.94)
        case .d: Color(red: 0.71, green: 0.75, blue: 0.80)
        }
    }
}
