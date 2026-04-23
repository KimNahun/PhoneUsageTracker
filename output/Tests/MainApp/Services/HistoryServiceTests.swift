import Testing
import Foundation
@testable import PhoneUsageTracker

struct HistoryServiceTests {
    @Test("recentSummary returns empty summary when no records exist")
    func recentSummaryEmptyWhenNoRecords() async throws {
        let mock = MockHistoryService(summary: HistorySummary.empty(), totalDays: 0)
        let summary = try await mock.recentSummary(days: 30)
        #expect(summary.points.isEmpty)
        #expect(summary.hasMinimumData == false)
    }

    @Test("recentSummary returns fixture with 20 days")
    func recentSummaryWith20Days() async throws {
        let fixture = HistorySummary.fixture(days: 20)
        let mock = MockHistoryService(summary: fixture)
        let summary = try await mock.recentSummary(days: 30)
        #expect(summary.points.count == 20)
        #expect(summary.hasMinimumData == true)
    }

    @Test("recentSummary throws when shouldThrow is true")
    func recentSummaryThrows() async {
        let mock = MockHistoryService(shouldThrow: true)
        await #expect(throws: MockError.forced) {
            _ = try await mock.recentSummary(days: 30)
        }
    }

    @Test("totalRecordedDays returns expected count")
    func totalRecordedDaysCount() async throws {
        let mock = MockHistoryService(totalDays: 15)
        let days = try await mock.totalRecordedDays()
        #expect(days == 15)
    }
}
