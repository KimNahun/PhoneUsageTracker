import Foundation

public enum SegmentKind: Sendable {
    case hourly
    case daily
    case monthlyDerived
}

public enum DateRange: String, CaseIterable, Identifiable, Sendable {
    case today
    case week
    case month
    case year

    public var id: String { rawValue }

    public var localizedTitle: String {
        switch self {
        case .today: return "오늘"
        case .week:  return "이번 주"
        case .month: return "이번 달"
        case .year:  return "올해"
        }
    }

    nonisolated public func currentInterval(now: Date = .now, calendar: Calendar = .current) -> DateInterval {
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            return DateInterval(start: start, end: now)
        case .week:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            let start = calendar.date(from: components) ?? now
            return DateInterval(start: start, end: now)
        case .month:
            let components = calendar.dateComponents([.year, .month], from: now)
            let start = calendar.date(from: components) ?? now
            return DateInterval(start: start, end: now)
        case .year:
            let components = calendar.dateComponents([.year], from: now)
            let start = calendar.date(from: components) ?? now
            return DateInterval(start: start, end: now)
        }
    }

    public var segmentIntervalKind: SegmentKind {
        switch self {
        case .today:        return .hourly
        case .week, .month: return .daily
        case .year:         return .monthlyDerived
        }
    }
}
