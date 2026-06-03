import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenStartupNotice") private var hasSeenStartupNotice = false
    @State private var showNotice = true
    @State private var selectedPortal: Portal?

    var body: some View {
        ZStack {
            if let selectedPortal {
                SafariPortalScreen(portal: selectedPortal) {
                    self.selectedPortal = nil
                }
            } else {
                PortalSelectorView { portal in
                    selectedPortal = portal
                }
            }
        }
        .alert("📢 小狗酒馆公告", isPresented: Binding(
            get: { showNotice && !hasSeenStartupNotice },
            set: { showNotice = $0 }
        )) {
            Button("进入酒馆") { showNotice = false }
            Button("以后不再显示") {
                hasSeenStartupNotice = true
                showNotice = false
            }
        } message: {
            Text("iOS 版已删除缓存状态 / 小狗加速器提示。Safari 兼容模式新增小狗工具箱：声音开关、手动回复提醒、刷新、截图、复制/分享入口、换狗洞、重置、小说化阅读器。")
        }
    }
}
