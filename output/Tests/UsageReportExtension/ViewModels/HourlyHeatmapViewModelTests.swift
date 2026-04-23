import Testing
import Foundation
@testable import UsageReportExtension

@MainActor
struct HourlyHeatmapViewModelTests {
    @Test("normalizedValue returns correct proportion")
    func normalizedValueIsCorrect() {
        let cell = HeatmapCell(weekday: 2, hour: 10, seconds: 1800)
        let config = HourlyHeatmapConfiguration(cells: [cell], max: 3600, peak: cell)
        let vm = HourlyHeatmapViewModel(configuration: config)
        let norm = vm.normalizedValue(for: cell)
        #expect(norm == 0.5)
    }

    @Test("maxValue defaults to 1 when config max is zero")
    func maxValueDefaultsToOneWhenZero() {
        let config = HourlyHeatmapConfiguration(cells: [], max: 0, peak: nil)
        let vm = HourlyHeatmapViewModel(configuration: config)
        #expect(vm.maxValue == 1)
    }

    @Test("selectCell updates selectedCell")
    func selectCellUpdatesState() {
        let cell = HeatmapCell(weekday: 3, hour: 14, seconds: 900)
        let vm = HourlyHeatmapViewModel()
        vm.selectCell(cell)
        #expect(vm.selectedCell?.weekday == 3)
        #expect(vm.selectedCell?.hour == 14)
    }

    @Test("selectCell nil clears selectedCell")
    func selectCellNilClears() {
        let cell = HeatmapCell(weekday: 3, hour: 14, seconds: 900)
        let vm = HourlyHeatmapViewModel()
        vm.selectCell(cell)
        vm.selectCell(nil)
        #expect(vm.selectedCell == nil)
    }
}
