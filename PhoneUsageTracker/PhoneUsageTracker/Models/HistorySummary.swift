import Foundation

public struct HistorySummary: Sendable {
    public struct DailyPoint: Sendable, Identifiable {
        public let id: Date
        public let date: Date
        public let totalSeconds: Double

        public init(date: Date, totalSeconds: Double) {
            self.id = date
            self.date = date
            self.totalSeconds = totalSeconds
        }
    }

    public let points: [DailyPoint]
    public let weekOverWeekDelta: Double?
    public let monthOverMonthDelta: Double?
    public let highestDay: DailyPoint?
    public let lowestDay: DailyPoint?

    public var hasMinimumData: Bool { points.count >= 14 }

    public init(
        points: [DailyPoint],
        weekOverWeekDelta: Double?,
        monthOverMonthDelta: Double?,
        highestDay: DailyPoint?,
        lowestDay: DailyPoint?
    ) {
        self.points = points
        self.weekOverWeekDelta = weekOverWeekDelta
        self.monthOverMonthDelta = monthOverMonthDelta
        self.highestDay = highestDay
        self.lowestDay = lowestDay
    }

    public static func empty() -> HistorySummary {
        HistorySummary(
            points: [],
            weekOverWeekDelta: nil,
            monthOverMonthDelta: nil,
            highestDay: nil,
            lowestDay: nil
        )
    }

    public static func fixture(days: Int) -> HistorySummary {
        let calendar = Calendar.current
        let now = Date()
        let points = (0..<days).map { offset -> DailyPoint in
            let date = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
            return DailyPoint(date: date, totalSeconds: Double.random(in: 1800...14400))
        }
        return HistorySummary(
            points: points.reversed(),
            weekOverWeekDelta: nil,
            monthOverMonthDelta: nil,
            highestDay: points.max(by: { $0.totalSeconds < $1.totalSeconds }),
            lowestDay: points.min(by: { $0.totalSeconds < $1.totalSeconds })
        )
    }
}
