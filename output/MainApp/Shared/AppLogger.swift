import os

extension Logger {
    private nonisolated(unsafe) static let subsystem = "com.nahun.PhoneUsageTracker"

    nonisolated(unsafe) static let permission = Logger(subsystem: subsystem, category: "permission")
    nonisolated(unsafe) static let filter     = Logger(subsystem: subsystem, category: "filter")
    nonisolated(unsafe) static let history    = Logger(subsystem: subsystem, category: "history")
    nonisolated(unsafe) static let settings   = Logger(subsystem: subsystem, category: "settings")
}
