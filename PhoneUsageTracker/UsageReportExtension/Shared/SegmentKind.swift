import Foundation

// Mirror of the main app's SegmentKind — both targets compile independently
public enum SegmentKind: Sendable {
    case hourly
    case daily
    case monthlyDerived
}
