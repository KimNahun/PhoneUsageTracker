import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import SwiftUI

struct AppDetailScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appDetail
    let content: (AppDetailConfiguration) -> AppDetailView

    init(content: @escaping (AppDetailConfiguration) -> AppDetailView = { AppDetailView(configuration: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> AppDetailConfiguration {
        ExtensionLogger.scene.info("AppDetailScene.makeConfiguration 시작")
        var bucketMap: [Date: Double] = [:]
        var targetToken: ApplicationToken?
        var totalSeconds: Double = 0

        for await activityData in data {
            for await activitySegment in activityData.activitySegments {
                for await categoryActivity in activitySegment.categories {
                    for await appActivity in categoryActivity.applications {
                        guard let token = appActivity.application.token else { continue }
                        if targetToken == nil { targetToken = token }
                        let duration = appActivity.totalActivityDuration
                        totalSeconds += duration
                        bucketMap[activitySegment.dateInterval.start, default: 0] += duration
                    }
                }
            }
        }

        let sortedDates = bucketMap.keys.sorted()
        let buckets = sortedDates.map { date in
            BucketPoint(date: date, totalSeconds: bucketMap[date] ?? 0, kind: .hour)
        }

        let config = AppDetailConfiguration(token: targetToken, buckets: buckets, totalSeconds: totalSeconds)
        ExtensionLogger.scene.info("AppDetailScene.makeConfiguration 완료: \(totalSeconds)s")
        return config
    }
}
