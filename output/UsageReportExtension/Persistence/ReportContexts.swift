import Foundation
import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings

// MARK: - Context constants

public extension DeviceActivityReport.Context {
    static let totalActivity     = Self("totalActivity")
    static let appRanking        = Self("appRanking")
    static let categoryBreakdown = Self("categoryBreakdown")
    static let hourlyHeatmap     = Self("hourlyHeatmap")
    static let appDetail         = Self("appDetail")
}

// MARK: - Shared bucket types

public struct BucketPoint: Sendable, Identifiable {
    public enum Kind: Sendable { case hour, day, month }
    public let id: Date
    public let date: Date
    public let totalSeconds: Double
    public let kind: Kind

    public init(date: Date, totalSeconds: Double, kind: Kind) {
        self.id = date
        self.date = date
        self.totalSeconds = totalSeconds
        self.kind = kind
    }
}

// MARK: - Configurations

public struct TotalActivityConfiguration: Sendable {
    public let totalSeconds: Double
    public let buckets: [BucketPoint]
    public let segmentKind: SegmentKind
    public let pickupCount: Int
    public let notificationCount: Int
    public let isEmpty: Bool

    public static var empty: TotalActivityConfiguration {
        TotalActivityConfiguration(
            totalSeconds: 0,
            buckets: [],
            segmentKind: .hourly,
            pickupCount: 0,
            notificationCount: 0,
            isEmpty: true
        )
    }
}

public struct AppRankingRow: Sendable, Identifiable {
    public let id: UUID
    public let token: ApplicationToken
    public let seconds: Double
    public let share: Double

    public init(token: ApplicationToken, seconds: Double, share: Double) {
        self.id = UUID()
        self.token = token
        self.seconds = seconds
        self.share = share
    }
}

public struct AppRankingConfiguration: Sendable {
    public let rows: [AppRankingRow]
    public let totalSeconds: Double
}

public struct CategorySlice: Sendable, Identifiable {
    public let id: UUID
    public let token: ActivityCategoryToken
    public let seconds: Double
    public let share: Double

    public init(token: ActivityCategoryToken, seconds: Double, share: Double) {
        self.id = UUID()
        self.token = token
        self.seconds = seconds
        self.share = share
    }
}

public struct CategoryBreakdownConfiguration: Sendable {
    public let slices: [CategorySlice]
    public let totalSeconds: Double
}

public struct HeatmapCell: Sendable, Identifiable {
    public let id: UUID
    public let weekday: Int   // 1=Sunday…7=Saturday
    public let hour: Int      // 0…23
    public let seconds: Double

    public init(weekday: Int, hour: Int, seconds: Double) {
        self.id = UUID()
        self.weekday = weekday
        self.hour = hour
        self.seconds = seconds
    }
}

public struct HourlyHeatmapConfiguration: Sendable {
    public let cells: [HeatmapCell]
    public let max: Double
    public let peak: HeatmapCell?
}

public struct AppDetailConfiguration: Sendable {
    public let token: ApplicationToken?
    public let buckets: [BucketPoint]
    public let totalSeconds: Double
    public var isEmpty: Bool { token == nil || buckets.isEmpty }
}
