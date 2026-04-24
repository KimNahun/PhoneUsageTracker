import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import SwiftUI

struct TotalActivityScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (TotalActivityConfiguration) -> TotalActivityView

    init(content: @escaping (TotalActivityConfiguration) -> TotalActivityView = { TotalActivityView(configuration: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> TotalActivityConfiguration {
        ExtensionLogger.scene.info("TotalActivityScene.makeConfiguration 시작")

        var totalSeconds: Double = 0
        // bucket key: truncated date (start of hour or start of day depending on filter)
        var bucketMap: [Date: Double] = [:]

        for await activityData in data {
            for await activitySegment in activityData.activitySegments {
                // ActivitySegment: has dateInterval, totalActivityDuration, .applications, .categories
                let duration = activitySegment.totalActivityDuration
                totalSeconds += duration

                // Use the segment's start date as the bucket key
                let bucketDate = activitySegment.dateInterval.start
                bucketMap[bucketDate, default: 0] += duration
            }
        }

        guard !bucketMap.isEmpty else {
            ExtensionLogger.scene.info("TotalActivityScene: no data — isEmpty=true")
            return TotalActivityConfiguration.empty
        }

        // Infer segmentKind from the gap between consecutive bucket dates
        let sortedDates = bucketMap.keys.sorted()
        let segmentKind: SegmentKind
        if sortedDates.count >= 2 {
            let diff = sortedDates[1].timeIntervalSince(sortedDates[0])
            // ≤ 1 hour → hourly, ≤ 2 days → daily, else → monthly
            if diff <= 3_600 {
                segmentKind = .hourly
            } else if diff <= 172_800 {
                segmentKind = .daily
            } else {
                segmentKind = .monthlyDerived
            }
        } else {
            segmentKind = .daily
        }

        let bucketKind: BucketPoint.Kind
        switch segmentKind {
        case .hourly:          bucketKind = .hour
        case .daily:           bucketKind = .day
        case .monthlyDerived:  bucketKind = .month
        }

        let buckets = sortedDates.map { date in
            BucketPoint(date: date, totalSeconds: bucketMap[date] ?? 0, kind: bucketKind)
        }

        // Persist daily aggregate when filter is daily-bucketed
        if segmentKind == .daily {
            await persistDailyData(
                buckets: buckets,
                pickupCount: nil,
                notificationCount: nil
            )
        }

        // Note: DeviceActivityResults does not expose pickup/notification counts directly.
        // These fields are nil to indicate "not available" and the UI shows "미지원".
        let config = TotalActivityConfiguration(
            totalSeconds: totalSeconds,
            buckets: buckets,
            segmentKind: segmentKind,
            pickupCount: nil,
            notificationCount: nil,
            isEmpty: false
        )
        ExtensionLogger.scene.info("TotalActivityScene.makeConfiguration 완료: \(totalSeconds)s, \(buckets.count) buckets")
        return config
    }

    private func persistDailyData(
        buckets: [BucketPoint],
        pickupCount: Int?,
        notificationCount: Int?
    ) async {
        guard let writer = try? DailyAggregateWriter() else { return }
        let total = buckets.reduce(0) { $0 + $1.totalSeconds }
        do {
            // Persist aggregate total under an empty-data sentinel token
            // Per-app data is persisted by AppRankingScene with real tokens
            try await writer.write(
                date: Date(),
                perApp: [(tokenData: Data("__total__".utf8), seconds: total)],
                pickupCount: pickupCount ?? 0,
                notificationCount: notificationCount ?? 0
            )
        } catch {
            ExtensionLogger.persistence.error("TotalActivityScene persist 실패: \(error)")
        }
    }
}
