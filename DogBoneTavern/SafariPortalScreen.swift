import SwiftUI
import SafariServices
import WebKit
import UIKit
import AudioToolbox
import UserNotifications

struct SafariPortalScreen: View {
    let portal: Portal
    let onSwitchPortal: () -> Void

    @AppStorage("soundEnabled") private var soundEnabled = true
    @State private var showSafari = true
    @State private var showNovelReader = false
    @State private var showExperimentalWebView = false
    @State private var showResetConfirm = false
    @State private var showTools = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var safariRefreshID = UUID()
    @State private var reminderActive = false
    @State private var reminderSeconds = 75

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#07111F"), Color(hex: "#102A43"), Color(hex: "#0B2545")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("🐶")
                        .font(.system(size: 64))

                    Text(portal.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("已启用 iOS Safari 兼容模式。这个模式优先用系统 Safari 网页容器打开 SillyTavern，避开内置 WKWebView 对 HTTP 狗洞的限制。")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)

                    Text(portal.url)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                        .padding(.horizontal, 22)

                    VStack(spacing: 12) {
                        Button {
                            showSafari = true
                        } label: {
                            Label("打开酒馆", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showTools = true
                        } label: {
                            Label("小狗工具箱", systemImage: "pawprint.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white)

                        Button {
                            showExperimentalWebView = true
                        } label: {
                            Label("高级内置 WebView", systemImage: "network")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    Text("提示：Safari 兼容模式更容易进入酒馆；AI 自动回复检测、整页长截图这类需要读网页内容的功能，只有高级内置 WebView 才能真正做到。")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
            }
            .navigationTitle("狗骨酒馆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("换狗洞") { onSwitchPortal() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("工具") { showTools = true }
                    Button("阅读器") { showNovelReader = true }
                    Button("重置") { showResetConfirm = true }
                }
            }
            .fullScreenCover(isPresented: $showSafari) {
                SafariCompatShell(
                    urlString: portal.url,
                    refreshID: safariRefreshID,
                    soundEnabled: soundEnabled,
                    reminderActive: reminderActive,
                    onClose: { showSafari = false },
                    onSwitchPortal: {
                        showSafari = false
                        onSwitchPortal()
                    },
                    onReader: {
                        showSafari = false
                        showNovelReader = true
                    },
                    onTools: { showTools = true },
                    onRefresh: { safariRefreshID = UUID() },
                    onReset: { showResetConfirm = true },
                    onToggleSound: { soundEnabled.toggle() },
                    onReplyReminder: { startReplyReminder() },
                    onShareLink: { share([portal.url]) },
                    onCopyLink: { copyToClipboard(portal.url) },
                    onScreenshot: { makeVisibleScreenshot() },
                    onOpenExternalSafari: { openExternalSafari() }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showNovelReader) {
                NovelReaderView()
            }
            .sheet(isPresented: $showExperimentalWebView) {
                WebViewScreen(portal: portal, onSwitchPortal: onSwitchPortal)
            }
            .sheet(isPresented: $showTools) {
                safariToolsSheet
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(items: shareItems)
            }
            .alert("💣 重置网页数据？", isPresented: $showResetConfirm) {
                Button("取消", role: .cancel) {}
                Button("确定重置", role: .destructive) {
                    WebDataCleaner.clearAll { }
                    safariRefreshID = UUID()
                }
            } message: {
                Text("这会清空 iOS WKWebView 的 Cookie、缓存和网页数据。Safari 兼容模式的数据由系统 Safari 管理，如果仍有问题，请到 iPhone 设置 → Safari → 高级 → 网站数据里清理。")
            }
        }
    }

    private var safariToolsSheet: some View {
        NavigationStack {
            List {
                Section("Safari 兼容模式工具") {
                    Button(soundEnabled ? "🔊 声音：开" : "🔇 声音：关") { soundEnabled.toggle() }
                    Button(reminderActive ? "🔔 回复提醒守候中" : "🔔 开始回复提醒") { startReplyReminder() }
                    Button("📖 导入小说化阅读器") { showTools = false; showNovelReader = true }
                    Button("🔄 重新打开当前狗洞") { safariRefreshID = UUID(); showTools = false; showSafari = true }
                    Button("📋 复制当前入口") { copyToClipboard(portal.url) }
                    Button("📤 分享当前入口") { share([portal.url]) }
                    Button("📸 可见页面截图") { makeVisibleScreenshot() }
                    Button("🚪 换狗洞") { showTools = false; onSwitchPortal() }
                    Button("💣 重置网页数据", role: .destructive) { showTools = false; showResetConfirm = true }
                }

                Section("高级功能说明") {
                    Text("Safari 兼容模式不能读取 SillyTavern 页面 DOM，所以不能像 Android JSBridge 那样自动判断 AI 已回复、空回复、截断或报错。这里提供的是手动回复提醒：你发完消息后点一下，它会过一会儿提醒你回来看。")
                    Text("整页长截图和真正的网页内检测需要使用高级内置 WebView，因为只有 WKWebView 才允许 App 注入脚本和读取页面状态。")
                    Button("打开高级内置 WebView") { showTools = false; showExperimentalWebView = true }
                }
            }
            .navigationTitle("🐾 小狗工具箱")
            .toolbar { Button("完成") { showTools = false } }
        }
    }

    private func startReplyReminder() {
        reminderActive = true
        if soundEnabled { AudioServicesPlaySystemSound(1104) }
        LocalNotifier.scheduleReplyReminder(after: TimeInterval(reminderSeconds), sound: soundEnabled)
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(reminderSeconds)) {
            reminderActive = false
            if soundEnabled { AudioServicesPlaySystemSound(1007) }
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        if soundEnabled { AudioServicesPlaySystemSound(1104) }
    }

    private func share(_ items: [Any]) {
        shareItems = items
        showShareSheet = true
    }

    private func openExternalSafari() {
        if let url = URL(string: portal.url) {
            UIApplication.shared.open(url)
        }
    }

    private func makeVisibleScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("狗骨酒馆截图_\(Int(Date().timeIntervalSince1970)).png")
        if let data = image.pngData() {
            try? data.write(to: url)
            share([url])
        }
    }
}

struct SafariCompatShell: View {
    let urlString: String
    let refreshID: UUID
    let soundEnabled: Bool
    let reminderActive: Bool
    let onClose: () -> Void
    let onSwitchPortal: () -> Void
    let onReader: () -> Void
    let onTools: () -> Void
    let onRefresh: () -> Void
    let onReset: () -> Void
    let onToggleSound: () -> Void
    let onReplyReminder: () -> Void
    let onShareLink: () -> Void
    let onCopyLink: () -> Void
    let onScreenshot: () -> Void
    let onOpenExternalSafari: () -> Void

    @State private var expanded = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SafariWebView(urlString: urlString)
                .id(refreshID)
                .ignoresSafeArea()

            VStack(alignment: .trailing, spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) { expanded.toggle() }
                } label: {
                    Text("🐾")
                        .font(.system(size: 28))
                        .frame(width: 54, height: 54)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }

                if expanded {
                    VStack(alignment: .trailing, spacing: 8) {
                        toolButton(soundEnabled ? "🔊 声音 开" : "🔇 声音 关", action: onToggleSound)
                        toolButton(reminderActive ? "🔔 守候中" : "🔔 回复提醒", action: onReplyReminder)
                        toolButton("🔄 刷新", action: onRefresh)
                        toolButton("📖 阅读器", action: onReader)
                        toolButton("📸 截图", action: onScreenshot)
                        toolButton("📋 复制入口", action: onCopyLink)
                        toolButton("📤 分享入口", action: onShareLink)
                        toolButton("🧭 外部Safari", action: onOpenExternalSafari)
                        toolButton("🚪 换狗洞", action: onSwitchPortal)
                        toolButton("💣 重置", action: onReset)
                        toolButton("✕ 关闭", action: onClose)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.top, 52)
            .padding(.trailing, 12)
        }
    }

    private func toolButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.16)) { expanded = false }
            action()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(radius: 8)
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let urlString: String

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = URL(string: urlString) ?? URL(string: "about:blank")!
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = false

        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.dismissButtonStyle = .done
        controller.preferredBarTintColor = UIColor.black
        controller.preferredControlTintColor = UIColor.systemBlue
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum LocalNotifier {
    static func scheduleReplyReminder(after seconds: TimeInterval, sound: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🔔 小狗提醒"
            content.body = "可以回酒馆看看 AI 有没有回复啦汪～"
            if sound { content.sound = .default }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(10, seconds), repeats: false)
            let request = UNNotificationRequest(identifier: "dogbone.reply.reminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
