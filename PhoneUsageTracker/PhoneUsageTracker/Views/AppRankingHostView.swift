import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import PersonalColorDesignSystem

struct AppRankingHostView: View {
    let filter: DeviceActivityFilter

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        DeviceActivityReport(.appRanking, filter: filter)
                            .frame(minHeight: 400)
                    }
                    .accessibilityLabel("앱별 사용 시간 순위")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("앱 순위")
        .navigationBarTitleDisplayMode(.inline)
    }
}
