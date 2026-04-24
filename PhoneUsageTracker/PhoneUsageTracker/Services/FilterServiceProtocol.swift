import Foundation
import DeviceActivity

public protocol FilterServiceProtocol: Sendable {
    func buildFilter(for range: DateRange, now: Date) async -> DeviceActivityFilter
}
