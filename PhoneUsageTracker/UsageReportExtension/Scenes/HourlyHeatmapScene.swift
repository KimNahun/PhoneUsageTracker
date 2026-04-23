import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import SwiftUI

struct HourlyHeatmapScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .hourlyHeatmap
    let content: (HourlyHeatmapConfiguration) -> HourlyHeatmapView

    init(content: @escaping (HourlyHeatmapConfiguration) -> HourlyHeatmapView = { HourlyHeatmapView(configuration: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> HourlyHeatmapConfiguration {
        ExtensionLogger.scene.info("HourlyHeatmapScene.makeConfiguration 시작")

        let calendar = Calendar.current
        // [weekday(0-based)][hour] accumulator
        var grid = Array(repeating: Array(repeating: 0.0, count: 24), count: 7)

        for await activityData in data {
            for await activitySegment in activityData.activitySegments {
                let weekdayRaw = calendar.component(.weekday, from: activitySegment.dateInterval.start)
                let weekdayIdx = weekdayRaw - 1  // 0=Sunday … 6=Saturday
                let hour       = calendar.component(.hour, from: activitySegment.dateInterval.start)
                guard weekdayIdx >= 0, weekdayIdx < 7, hour >= 0, hour < 24 else { continue }
                grid[weekdayIdx][hour] += activitySegment.totalActivityDuration
            }
        }

        var cells: [HeatmapCell] = []
        var maxValue: Double = 0

        for weekdayIdx in 0..<7 {
            for hour in 0..<24 {
                let seconds = grid[weekdayIdx][hour]
                // weekday stored 1-based to match Calendar.component(.weekday)
                cells.append(HeatmapCell(weekday: weekdayIdx + 1, hour: hour, seconds: seconds))
                if seconds > maxValue { maxValue = seconds }
            }
        }

        let peak = cells.max(by: { $0.seconds < $1.seconds })
        let config = HourlyHeatmapConfiguration(cells: cells, max: maxValue, peak: peak)
        ExtensionLogger.scene.info("HourlyHeatmapScene.makeConfiguration 완료: max=\(maxValue)s")
        return config
    }
}
