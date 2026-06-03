import SwiftUI

extension Color {
    init(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "#", with: "")

        var value: UInt64 = 0
        Scanner(string: text).scanHexInt64(&value)

        let r: Double
        let g: Double
        let b: Double
        let a: Double

        switch text.count {
        case 8:
            a = Double((value & 0xFF000000) >> 24) / 255.0
            r = Double((value & 0x00FF0000) >> 16) / 255.0
            g = Double((value & 0x0000FF00) >> 8) / 255.0
            b = Double(value & 0x000000FF) / 255.0
        default:
            a = 1.0
            r = Double((value & 0xFF0000) >> 16) / 255.0
            g = Double((value & 0x00FF00) >> 8) / 255.0
            b = Double(value & 0x0000FF) / 255.0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
