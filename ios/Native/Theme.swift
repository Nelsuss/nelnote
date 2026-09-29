import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

/// 라이트·다크 모드에 따라 자동으로 바뀌는 색
enum Theme {
    static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
        let color = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(hex: dark)
            }
            return UIColor(hex: light)
        }
        return Color(color)
    }

    static let paper = adaptive(0xF4F6F9, 0x151923)
    static let card = adaptive(0xFFFFFF, 0x1D2230)
    static let ink = adaptive(0x1B2130, 0xE8EBF2)
    static let ink2 = adaptive(0x5D6577, 0xA0A8BB)
    static let ink3 = adaptive(0x8C94A5, 0x737B8F)
    static let rule = adaptive(0xD5DBE4, 0x2F3647)
    static let rule2 = adaptive(0xEAEEF3, 0x232938)
    static let slot = adaptive(0xC3CAD6, 0x465068)
    static let seal = adaptive(0xD8392B, 0xFF5A48)
    static let dockLine = adaptive(0xC8CED9, 0x3A4256)
}

extension Category {
    var ink: Color {
        switch self {
        case .game: return Theme.adaptive(0x0A8A64, 0x36CFA0)
        case .anime: return Theme.adaptive(0xD93370, 0xFF6A9E)
        case .vn: return Theme.adaptive(0x6A4BD6, 0xA58CFF)
        case .book: return Theme.adaptive(0xAE6A06, 0xF3AA3C)
        }
    }

    var symbol: String {
        switch self {
        case .game: return "gamecontroller"
        case .anime: return "tv"
        case .vn: return "ipad"
        case .book: return "book"
        }
    }
}

extension View {
    /// 배경 사진 위에서도 글씨가 잘 보이게 은은한 테두리 빛을 준다
    func glow(_ on: Bool) -> some View {
        return self.shadow(color: on ? Theme.paper : Color.clear, radius: 3, x: 0, y: 0)
    }
}
