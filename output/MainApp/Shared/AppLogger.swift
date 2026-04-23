import os

extension Logger {
    private static let subsystem = "com.nahun.PhoneUsageTracker"

    static let permission = Logger(subsystem: subsystem, category: "permission")
    static let filter     = Logger(subsystem: subsystem, category: "filter")
    static let history    = Logger(subsystem: subsystem, category: "history")
    static let settings   = Logger(subsystem: subsystem, category: "settings")
}
