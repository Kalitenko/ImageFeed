import UIKit

extension UIColor {
    convenience init(hex: String) throws {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            throw NSError(
                domain: "HexColorParsing",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid hex string format: \(hex)"]
            )
        }

        var r, g, b, a: CGFloat

        switch hexSanitized.count {
        case 6: // RGB
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // ARGB
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            throw NSError(
                domain: "HexColorParsing",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Hex string must be 6 or 8 characters long"]
            )
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
