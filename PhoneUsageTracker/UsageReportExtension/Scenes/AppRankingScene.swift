import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import SwiftUI

struct AppRankingScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appRanking
    let content: (AppRankingConfiguration) -> AppRankingView

    init(content: @escaping (AppRankingConfiguration) -> AppRankingView = { AppRankingView(configuration: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> AppRankingConfiguration {
        ExtensionLogger.scene.info("AppRankingScene.makeConfiguration 시작")

        // token → (token, tokenData, accumulatedSeconds)
        var tokenMap: [Data: (token: ApplicationToken, seconds: Double)] = [:]
        var totalSeconds: Double = 0

        for await activityData in data {
            for await activitySegment in activityData.activitySegments {
                for await categoryActivity in activitySegment.categories {
                    for await appActivity in categoryActivity.applications {
                        guard let token = appActivity.application.token else { continue }
                        let duration = appActivity.totalActivityDuration
                        totalSeconds += duration

                        if let tokenData = try? JSONEncoder().encode(token) {
                            if var entry = tokenMap[tokenData] {
                                entry.seconds += duration
                                tokenMap[tokenData] = entry
                            } else {
                                tokenMap[tokenData] = (token: token, seconds: duration)
                            }
                        }
                    }
                }
            }
        }

        let sorted = tokenMap.sorted { $0.value.seconds > $1.value.seconds }
        let rows = sorted.prefix(20).map { (tokenData, entry) in
            AppRankingRow(
                token: entry.token,
                seconds: entry.seconds,
                share: totalSeconds > 0 ? entry.seconds / totalSeconds : 0
            )
        }

        // Persist per-app daily data
        if !tokenMap.isEmpty {
            let perApp = tokenMap.map { (tokenData: $0.key, seconds: $0.value.seconds) }
            await persistAppData(perApp: perApp)
        }

        let config = AppRankingConfiguration(rows: Array(rows), totalSeconds: totalSeconds)
        ExtensionLogger.scene.info("AppRankingScene.makeConfiguration 완료: \(rows.count) apps, total=\(totalSeconds)s")
        return config
    }

    private func persistAppData(perApp: [(tokenData: Data, seconds: Double)]) async {
        guard let writer = try? DailyAggregateWriter() else { return }
        do {
            try await writer.write(
                date: Date(),
                perApp: perApp,
                pickupCount: 0,
                notificationCount: 0
            )
        } catch {
            ExtensionLogger.persistence.error("AppRankingScene persist 실패: \(error)")
        }
    }
}
