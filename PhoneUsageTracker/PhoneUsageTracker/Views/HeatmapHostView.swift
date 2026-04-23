import SwiftUI
import DeviceActivity
import PersonalColorDesignSystem

struct HeatmapHostView: View {
    let filter: DeviceActivityFilter

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        DeviceActivityReport(context: .hourlyHeatmap, filter: filter)
                            .frame(minHeight: 320)
                    }
                    .accessibilityLabel("시간대별 사용 히트맵")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("시간대 히트맵")
        .navigationBarTitleDisplayMode(.inline)
    }
}
