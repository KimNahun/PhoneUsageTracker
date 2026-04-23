import Foundation
import Observation

@MainActor
@Observable
final class TotalActivityViewModel {
    private(set) var totalSeconds: Double = 0
    private(set) var buckets: [BucketPoint] = []
    private(set) var segmentKind: SegmentKind = .hourly
    private(set) var pickupCount: Int = 0
    private(set) var notificationCount: Int = 0
    private(set) var isEmpty: Bool = true

    init(configuration: TotalActivityConfiguration? = nil) {
        if let config = configuration {
            apply(config)
        }
    }

    func apply(_ configuration: TotalActivityConfiguration) {
        ExtensionLogger.viewModel.info("TotalActivityViewModel.apply: \(configuration.buckets.count) buckets")
        totalSeconds      = configuration.totalSeconds
        buckets           = configuration.buckets
        segmentKind       = configuration.segmentKind
        pickupCount       = configuration.pickupCount
        notificationCount = configuration.notificationCount
        isEmpty           = configuration.isEmpty
    }
}
