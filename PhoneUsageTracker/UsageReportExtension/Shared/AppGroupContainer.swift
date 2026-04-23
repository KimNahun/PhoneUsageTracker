import Foundation
import SwiftData

public enum AppGroupContainer {
    public static let identifier = "group.com.nahun.PhoneUsageTracker"

    public static var url: URL {
        get throws {
            guard let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: identifier
            ) else {
                throw AppGroupError.containerUnavailable
            }
            return containerURL
        }
    }

    public static func makeModelContainer() throws -> ModelContainer {
        let storeURL = try url.appendingPathComponent("usage.sqlite")
        let config = ModelConfiguration(url: storeURL)
        return try ModelContainer(for: PersistedUsageRecord.self, configurations: config)
    }
}

enum AppGroupError: Error {
    case containerUnavailable
}
