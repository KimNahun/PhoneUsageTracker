import Foundation

public protocol HistoryServiceProtocol: Sendable {
    func recentSummary(days: Int) async throws -> HistorySummary
    func totalRecordedDays() async throws -> Int
}
