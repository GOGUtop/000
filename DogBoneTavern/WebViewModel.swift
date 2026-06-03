import Foundation
import WebKit

final class WebViewModel: ObservableObject {
    weak var webView: WKWebView?

    @Published var title: String = "狗骨酒馆"
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func reload() {
        errorMessage = nil
        webView?.reload()
    }

    func loadCurrentAgain() {
        errorMessage = nil
        if let url = webView?.url {
            webView?.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 45))
        } else {
            webView?.reload()
        }
    }

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
}
