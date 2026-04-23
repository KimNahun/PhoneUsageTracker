import Foundation

struct DependencyContainer: Sendable {
    let authorizationService: any AuthorizationServiceProtocol
    let filterService: any FilterServiceProtocol
    let historyService: any HistoryServiceProtocol
    let retentionService: any RetentionServiceProtocol

    static func live() throws -> DependencyContainer {
        let container = try AppGroupContainer.makeModelContainer()
        return DependencyContainer(
            authorizationService: AuthorizationService(),
            filterService: FilterService(),
            historyService: HistoryService(modelContainer: container),
            retentionService: RetentionService(modelContainer: container)
        )
    }
}
