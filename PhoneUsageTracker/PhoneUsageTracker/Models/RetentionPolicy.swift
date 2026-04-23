import Foundation

public enum RetentionPolicy: Int, CaseIterable, Sendable, Identifiable {
    case days90    = 90
    case days365   = 365
    case unlimited = 0

    public var id: Int { rawValue }

    public var localizedTitle: String {
        switch self {
        case .days90:    return "90일"
        case .days365:   return "1년"
        case .unlimited: return "무제한"
        }
    }
}
