import Foundation
import SwiftData
import os

actor HistoryService: HistoryServiceProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func recentSummary(days: Int) async throws -> HistorySummary {
        Logger.history.info("recentSummary 시작: days=\(days)")
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let now = Date()
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: now) else {
            return HistorySummary.empty()
        }

        let descriptor = FetchDescriptor<PersistedUsageRecord>(
            predicate: #Predicate { $0.date >= cutoff },
            sortBy: [SortDescriptor(\PersistedUsageRecord.date)]
        )
        let records = try context.fetch(descriptor)

        // Aggregate per-day (sum across all apps for that day)
        var dayTotals: [Date: (seconds: Double, pickups: Int)] = [:]
        for record in records {
            let dayStart = calendar.startOfDay(for: record.date)
            let existing = dayTotals[dayStart] ?? (0, 0)
            dayTotals[dayStart] = (existing.seconds + record.totalSeconds, existing.pickups + record.pickupCount)
        }

        let sortedDays = dayTotals.keys.sorted()
        let points = sortedDays.map { date in
            HistorySummary.DailyPoint(date: date, totalSeconds: dayTotals[date]!.seconds)
        }

        // Compute deltas
        let weekOverWeekDelta = computeDelta(points: points, daysAgo: 7)
        let monthOverMonthDelta = computeDelta(points: points, daysAgo: 30)

        let highestDay = points.max(by: { $0.totalSeconds < $1.totalSeconds })
        let lowestDay  = points.min(by: { $0.totalSeconds < $1.totalSeconds })

        Logger.history.info("recentSummary 완료: \(points.count)일 데이터")
        return HistorySummary(
            points: Array(points.suffix(30)),
            weekOverWeekDelta: weekOverWeekDelta,
            monthOverMonthDelta: monthOverMonthDelta,
            highestDay: highestDay,
            lowestDay: lowestDay
        )
    }

    func totalRecordedDays() async throws -> Int {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<PersistedUsageRecord>()
        let records = try context.fetch(descriptor)
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        return uniqueDays.count
    }

    private func computeDelta(points: [HistorySummary.DailyPoint], daysAgo: Int) -> Double? {
        guard points.count >= daysAgo * 2 else { return nil }
        let recent = points.suffix(daysAgo).reduce(0) { $0 + $1.totalSeconds }
        let previous = points.dropLast(daysAgo).suffix(daysAgo).reduce(0) { $0 + $1.totalSeconds }
        guard previous > 0 else { return nil }
        return (recent - previous) / previous
    }
}
