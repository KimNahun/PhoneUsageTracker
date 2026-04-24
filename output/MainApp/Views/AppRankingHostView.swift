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
                    Text("전체 앱 목록")
                        .font(.pCaption(12))
                        .foregroundStyle(Color.pTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .accessibilityAddTraits(.isHeader)

                    GlassCard {
                        DeviceActivityReport(.appRanking, filter: filter)
                            .frame(minHeight: 400)
                    }
                    .accessibilityLabel("앱별 사용 시간 순위")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("앱 순위")
        .navigationBarTitleDisplayMode(.inline)
    }
}
