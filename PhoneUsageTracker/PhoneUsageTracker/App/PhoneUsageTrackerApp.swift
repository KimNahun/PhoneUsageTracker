import SwiftUI
import SwiftData

@main
struct PhoneUsageTrackerApp: App {
    private let dependencies: DependencyContainer

    init() {
        do {
            dependencies = try DependencyContainer.live()
        } catch {
            fatalError("DependencyContainer 초기화 실패: \(error)")
        }
        applyStoredRetentionPolicy()
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .preferredColorScheme(.dark)
        }
    }

    private func applyStoredRetentionPolicy() {
        let rawValue = UserDefaults.standard.integer(forKey: "retentionPolicyRaw")
        let policy = RetentionPolicy(rawValue: rawValue) ?? .days365
        let retentionService = dependencies.retentionService
        Task {
            try? await retentionService.apply(policy)
        }
    }
}
