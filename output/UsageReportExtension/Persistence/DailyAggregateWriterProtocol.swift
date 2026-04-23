import Foundation

public protocol DailyAggregateWriterProtocol: Sendable {
    func write(
        date: Date,
        perApp: [(tokenData: Data, seconds: Double)],
        pickupCount: Int,
        notificationCount: Int
    ) async throws
}
