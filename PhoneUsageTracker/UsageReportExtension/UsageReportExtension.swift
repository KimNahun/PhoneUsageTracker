import DeviceActivity
import _DeviceActivity_SwiftUI
import SwiftUI

// MARK: - 최소 테스트용 (디버깅 후 원복)
@main
struct UsageReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        MinimalTestScene()
    }
}

struct MinimalTestScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init("totalActivity")
    let content: (String) -> MinimalTestView

    init(content: @escaping (String) -> MinimalTestView = { MinimalTestView(message: $0) }) {
        self.content = content
    }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        return "Extension 로드 성공! 데이터 항목: \(data.flatMap { _ in [1] }.count)"
    }
}

struct MinimalTestView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.title)
            .foregroundStyle(.white)
            .padding()
            .background(Color.green.opacity(0.5))
            .cornerRadius(12)
    }
}
