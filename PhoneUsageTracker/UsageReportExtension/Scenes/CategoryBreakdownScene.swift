import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import SwiftUI

struct CategoryBreakdownScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .categoryBreakdown
    let content: (CategoryBreakdownConfiguration) -> CategoryBreakdownView

    init(content: @escaping (CategoryBreakdownConfiguration) -> CategoryBreakdownView = { CategoryBreakdownView(configuration: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> CategoryBreakdownConfiguration {
        ExtensionLogger.scene.info("CategoryBreakdownScene.makeConfiguration 시작")

        // category token → accumulated seconds
        // ActivityCategoryToken: Hashable + Equatable
        var categoryMap: [(token: ActivityCategoryToken, seconds: Double)] = []
        var totalSeconds: Double = 0

        for await activityData in data {
            for await activitySegment in activityData.activitySegments {
                for await categoryActivity in activitySegment.categories {
                    let token    = categoryActivity.category.token
                    let duration = categoryActivity.totalActivityDuration
                    totalSeconds += duration
                    if let idx = categoryMap.firstIndex(where: { $0.token == token }) {
                        categoryMap[idx].seconds += duration
                    } else {
                        categoryMap.append((token: token, seconds: duration))
                    }
                }
            }
        }

        let sorted = categoryMap.sorted { $0.seconds > $1.seconds }
        let slices = sorted.map { entry in
            CategorySlice(
                token: entry.token,
                seconds: entry.seconds,
                share: totalSeconds > 0 ? entry.seconds / totalSeconds : 0
            )
        }

        let config = CategoryBreakdownConfiguration(slices: slices, totalSeconds: totalSeconds)
        ExtensionLogger.scene.info("CategoryBreakdownScene.makeConfiguration 완료: \(slices.count) categories")
        return config
    }
}
