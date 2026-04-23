import Foundation

struct MockHistoryService: HistoryServiceProtocol {
    var summary: HistorySummary
    var totalDays: Int
    var shouldThrow: Bool

    init(
        summary: HistorySummary = HistorySummary.empty(),
        totalDays: Int = 0,
        shouldThrow: Bool = false
    ) {
        self.summary = summary
        self.totalDays = totalDays
        self.shouldThrow = shouldThrow
    }

    func recentSummary(days: Int) async throws -> HistorySummary {
        if shouldThrow { throw MockError.forced }
        return summary
    }

    func totalRecordedDays() async throws -> Int {
        if shouldThrow { throw MockError.forced }
        return totalDays
    }
}

enum MockError: Error {
    case forced
}
