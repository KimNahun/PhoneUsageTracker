import os

enum ExtensionLogger {
    private static let subsystem = "com.nahun.PhoneUsageTracker.UsageReport"

    static let scene       = Logger(subsystem: subsystem, category: "scene")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let viewModel   = Logger(subsystem: subsystem, category: "viewModel")
}
