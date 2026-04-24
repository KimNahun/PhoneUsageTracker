import Foundation
import Observation

@MainActor
@Observable
final class AppRankingViewModel {
    private(set) var rows: [AppRankingRow] = []
    private(set) var totalSeconds: Double = 0
    private(set) var perAppBuckets: [Data: [BucketPoint]] = [:]

    init(configuration: AppRankingConfiguration? = nil) {
        if let config = configuration {
            apply(config)
        }
    }

    func apply(_ configuration: AppRankingConfiguration) {
        ExtensionLogger.viewModel.info("AppRankingViewModel.apply: \(configuration.rows.count) rows")
        rows = configuration.rows
        totalSeconds = configuration.totalSeconds
        perAppBuckets = configuration.perAppBuckets
    }

    func buckets(for row: AppRankingRow) -> [BucketPoint] {
        guard let tokenData = try? JSONEncoder().encode(row.token) else { return [] }
        return perAppBuckets[tokenData] ?? []
    }
}
