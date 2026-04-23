import Foundation
import Observation

@MainActor
@Observable
final class HourlyHeatmapViewModel {
    private(set) var cells: [HeatmapCell] = []
    private(set) var maxValue: Double = 1
    private(set) var peak: HeatmapCell?
    private(set) var selectedCell: HeatmapCell?

    init(configuration: HourlyHeatmapConfiguration? = nil) {
        if let config = configuration {
            apply(config)
        }
    }

    func apply(_ configuration: HourlyHeatmapConfiguration) {
        ExtensionLogger.viewModel.info("HourlyHeatmapViewModel.apply: \(configuration.cells.count) cells")
        cells    = configuration.cells
        maxValue = configuration.max > 0 ? configuration.max : 1
        peak     = configuration.peak
    }

    func selectCell(_ cell: HeatmapCell?) {
        selectedCell = cell
    }

    func normalizedValue(for cell: HeatmapCell) -> Double {
        cell.seconds / maxValue
    }
}
