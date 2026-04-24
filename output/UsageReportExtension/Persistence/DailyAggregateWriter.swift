import Foundation
import SwiftData
import os

actor DailyAggregateWriter: DailyAggregateWriterProtocol {
    // Single container instance shared within the Extension process
    static let sharedContainer: ModelContainer? = try? AppGroupContainer.makeModelContainer()

    private let modelContainer: ModelContainer

    init() throws {
        guard let container = DailyAggregateWriter.sharedContainer else {
            throw DailyAggregateWriterError.containerUnavailable
        }
        self.modelContainer = container
    }

    func write(
        date: Date,
        perApp: [(tokenData: Data, seconds: Double)],
        pickupCount: Int,
        notificationCount: Int
    ) async throws {
        ExtensionLogger.persistence.info("DailyAggregateWriter.write: \(perApp.count) apps, date=\(date)")
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)

        for entry in perApp {
            let tokenData = entry.tokenData
            let descriptor = FetchDescriptor<PersistedUsageRecord>(
                predicate: #Predicate {
                    $0.date == dayStart && $0.tokenIdentifier == tokenData
                }
            )
            let existing = try context.fetch(descriptor)
            if let record = existing.first {
                // upsert: keep the max value to handle partial-day updates
                record.totalSeconds = max(record.totalSeconds, entry.seconds)
                record.pickupCount = pickupCount
                record.notificationCount = notificationCount
            } else {
                let record = PersistedUsageRecord(
                    date: dayStart,
                    tokenIdentifier: entry.tokenData,
                    totalSeconds: entry.seconds,
                    pickupCount: pickupCount,
                    notificationCount: notificationCount
                )
                context.insert(record)
            }
        }
        try context.save()
        ExtensionLogger.persistence.info("DailyAggregateWriter.write 완료")
    }
}

enum DailyAggregateWriterError: Error {
    case containerUnavailable
}
