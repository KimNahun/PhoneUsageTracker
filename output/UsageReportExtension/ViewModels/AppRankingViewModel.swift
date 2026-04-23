import Foundation
import Observation

@MainActor
@Observable
final class AppRankingViewModel {
    private(set) var rows: [AppRankingRow] = []
    private(set) var totalSeconds: Double = 0

    init(configuration: AppRankingConfiguration? = nil) {
        if let config = configuration {
            apply(config)
        }
    }

    func apply(_ configuration: AppRankingConfiguration) {
        ExtensionLogger.viewModel.info("AppRankingViewModel.apply: \(configuration.rows.count) rows")
        rows = configuration.rows
        totalSeconds = configuration.totalSeconds
    }
}
