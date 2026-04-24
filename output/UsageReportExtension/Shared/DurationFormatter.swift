import Foundation

enum DurationFormatter {
    static func format(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
}
