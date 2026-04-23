import Foundation
import SwiftData

@Model
public final class PersistedUsageRecord {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var tokenIdentifier: Data
    public var totalSeconds: Double
    public var pickupCount: Int
    public var notificationCount: Int

    public init(
        id: UUID = UUID(),
        date: Date,
        tokenIdentifier: Data,
        totalSeconds: Double,
        pickupCount: Int,
        notificationCount: Int
    ) {
        self.id = id
        self.date = date
        self.tokenIdentifier = tokenIdentifier
        self.totalSeconds = totalSeconds
        self.pickupCount = pickupCount
        self.notificationCount = notificationCount
    }
}
