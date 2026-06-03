import SwiftUI

struct WebViewScreen: View {
    let portal: Portal
    let onSwitchPortal: () -> Void

    @StateObject private var model = WebViewModel()
    @State private var showResetConfirm = false
    @State private var showNovelReader = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                TavernWebView(urlString: portal.url, model: model)
                    .ignoresSafeArea(.keyboard)

                if model.isLoading {
                    ProgressView()
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }

                if let message = model.errorMessage {
                    VStack(spacing: 14) {
                        Text("🐶 没钻进去")
                            .font(.title2.bold())
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("当前入口：\(portal.url)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 12) {
                            Button("重新加载") { model.loadCurrentAgain() }
                                .buttonStyle(.borderedProminent)
                            Button("换狗洞") { onSwitchPortal() }
                                .buttonStyle(.bordered)
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: 340)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(radius: 20)
                    .padding(.top, 86)
                }
            }
            .navigationTitle(model.title.isEmpty ? portal.name : model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("返回") { model.goBack() }
                        .disabled(!model.canGoBack)
                    Button("刷新") { model.reload() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("阅读器") { showNovelReader = true }
                    Button("换狗洞") { onSwitchPortal() }
                    Button("重置") { showResetConfirm = true }
                }
            }
            .alert("💣 重置狗骨酒馆？", isPresented: $showResetConfirm) {
                Button("取消", role: .cancel) {}
                Button("确定重置", role: .destructive) {
                    WebDataCleaner.clearAll { model.reload() }
                }
            } message: {
                Text("这会清空 iOS WKWebView 的 Cookie、缓存和网页数据，然后重新打开当前入口。")
            }
            .sheet(isPresented: $showNovelReader) {
                NovelReaderView()
            }
        }
    }
}
