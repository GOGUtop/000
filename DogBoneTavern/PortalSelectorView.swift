import SwiftUI

struct PortalSelectorView: View {
    @AppStorage("lastPortalURL") private var lastPortalURL = PortalStore.defaultURL
    let onSelect: (Portal) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#07111F"), Color(hex: "#102A43"), Color(hex: "#D8C08D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text("🦴")
                        .font(.system(size: 58))
                        .padding(.top, 36)

                    Text("狗骨酒馆")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color(hex: "#FFF4D6"))

                    Text("选一个云洞钻进去汪～")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.bottom, 12)

                    ForEach(PortalStore.portals) { portal in
                        portalCard(portal)
                    }

                    Text("💡 选错了也没事，进去后点右上角【换狗洞】即可切换")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 36)
            }
        }
    }

    private func portalCard(_ portal: Portal) -> some View {
        Button {
            lastPortalURL = portal.url
            onSelect(portal)
        } label: {
            HStack(spacing: 14) {
                Text(portal.emoji)
                    .font(.system(size: 34))
                    .frame(width: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text(portal.name)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                    Text(portal.desc)
                        .font(.system(size: 12))
                        .opacity(0.9)
                    if lastPortalURL == portal.url {
                        Text("✦ 上次使用")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#FFF4D6"))
                    }
                }
                Spacer()
                Text("›")
                    .font(.system(size: 34, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                LinearGradient(
                    colors: portal.gradient.map { Color(hex: $0).opacity(0.88) },
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(lastPortalURL == portal.url ? Color(hex: "#FFF4D6") : .white.opacity(0.45), lineWidth: lastPortalURL == portal.url ? 2 : 1)
            )
            .shadow(radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
