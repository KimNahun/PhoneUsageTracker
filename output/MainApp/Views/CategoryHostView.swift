import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import PersonalColorDesignSystem

struct CategoryHostView: View {
    let filter: DeviceActivityFilter

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        DeviceActivityReport(.categoryBreakdown, filter: filter)
                            .frame(minHeight: 360)
                    }
                    .accessibilityLabel("카테고리별 사용 시간 분석")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("카테고리 분석")
        .navigationBarTitleDisplayMode(.inline)
    }
}
