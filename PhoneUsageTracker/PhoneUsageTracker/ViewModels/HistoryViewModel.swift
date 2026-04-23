import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    private(set) var summary: HistorySummary?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let historyService: any HistoryServiceProtocol

    init(service: any HistoryServiceProtocol) {
        self.historyService = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            summary = try await historyService.recentSummary(days: 30)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
