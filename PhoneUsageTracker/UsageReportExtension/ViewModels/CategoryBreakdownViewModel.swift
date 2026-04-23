import Foundation
import Observation

@MainActor
@Observable
final class CategoryBreakdownViewModel {
    private(set) var slices: [CategorySlice] = []
    private(set) var totalSeconds: Double = 0

    init(configuration: CategoryBreakdownConfiguration? = nil) {
        if let config = configuration {
            apply(config)
        }
    }

    func apply(_ configuration: CategoryBreakdownConfiguration) {
        ExtensionLogger.viewModel.info("CategoryBreakdownViewModel.apply: \(configuration.slices.count) slices")
        slices = configuration.slices
        totalSeconds = configuration.totalSeconds
    }
}
