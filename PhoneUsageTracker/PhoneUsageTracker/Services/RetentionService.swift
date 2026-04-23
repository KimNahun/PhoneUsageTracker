import Foundation
import SwiftData
import os

actor RetentionService: RetentionServiceProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func apply(_ policy: RetentionPolicy) async throws {
        Logger.settings.info("apply retention policy: \(policy.rawValue)")
        guard policy != .unlimited else { return }

        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -policy.rawValue, to: Date()) else { return }

        let descriptor = FetchDescriptor<PersistedUsageRecord>(
            predicate: #Predicate { $0.date < cutoff }
        )
        let staleRecords = try context.fetch(descriptor)
        for record in staleRecords {
            context.delete(record)
        }
        try context.save()
        Logger.settings.info("apply retention 완료: \(staleRecords.count)건 삭제")
    }

    func clearAll() async throws {
        Logger.settings.info("clearAll 시작")
        let context = ModelContext(modelContainer)
        try context.delete(model: PersistedUsageRecord.self)
        try context.save()
        Logger.settings.info("clearAll 완료")
    }
}
