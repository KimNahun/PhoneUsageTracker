import Testing
import Foundation
@testable import PhoneUsageTracker

struct HistorySummaryTests {
    @Test("hasMinimumData returns false when fewer than 14 points")
    func hasMinimumDataReturnsFalseBelow14() {
        let summary = HistorySummary.fixture(days: 5)
        #expect(summary.hasMinimumData == false)
    }

    @Test("hasMinimumData returns true with exactly 14 points")
    func hasMinimumDataReturnsTrueAt14() {
        let summary = HistorySummary.fixture(days: 14)
        #expect(summary.hasMinimumData == true)
    }

    @Test("empty() returns summary with no points")
    func emptyReturnsNoPoints() {
        let summary = HistorySummary.empty()
        #expect(summary.points.isEmpty)
        #expect(summary.weekOverWeekDelta == nil)
        #expect(summary.monthOverMonthDelta == nil)
    }

    @Test("fixture produces the requested number of points")
    func fixtureProducesCorrectCount() {
        let summary = HistorySummary.fixture(days: 10)
        #expect(summary.points.count == 10)
    }

    @Test("DailyPoint id equals date")
    func dailyPointIdEqualsDate() {
        let date = Date()
        let point = HistorySummary.DailyPoint(date: date, totalSeconds: 3600)
        #expect(point.id == date)
        #expect(point.date == date)
        #expect(point.totalSeconds == 3600)
    }
}
