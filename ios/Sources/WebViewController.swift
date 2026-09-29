import UIKit
import WebKit

/// 화면은 Web/index.html 이 그리고, 이 컨트롤러는 그 화면을 담는 틀 역할만 한다.
final class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    private static let paper = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 21.0 / 255.0, green: 25.0 / 255.0, blue: 35.0 / 255.0, alpha: 1)
        }
        return UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
    }

    private let store = Store()
    private var webView: WKWebView!
    private var started = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.paper

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "nel")

        let web = WKWebView(frame: .zero, configuration: configuration)
        web.translatesAutoresizingMaskIntoConstraints = false
        web.isOpaque = false
        web.backgroundColor = Self.paper
        web.scrollView.backgroundColor = Self.paper
        web.scrollView.contentInsetAdjustmentBehavior = .never // 노치·홈 바 여백은 화면(CSS)이 직접 처리
        web.scrollView.bounces = false
        web.navigationDelegate = self
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webView = web
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 창에 붙은 뒤에 열어야 다크 모드 여부를 정확히 알 수 있다
        if !started {
            started = true
            loadPage()
        }
    }

    // MARK: 화면 열기

    private func loadPage() {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") else {
            return
        }
        // 열 때마다 저장된 최신 값을 다시 넣어 준다 (화면 엔진이 멈췄다 되살아날 때도 안전)
        let content = webView.configuration.userContentController
        content.removeAllUserScripts()
        content.addUserScript(WKUserScript(source: injectedSource(),
                                           injectionTime: .atDocumentStart,
                                           forMainFrameOnly: true))
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    private func injectedSource() -> String {
        let payload: [String: Any] = [
            "data": store.readText("dojang.json"),
            "dark": traitCollection.userInterfaceStyle == .dark,
            "bg": ["home": store.readText("bg_home.txt"), "cat": store.readText("bg_cat.txt")],
            "prefs": store.readPrefs()
        ]
        let json = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data("{}".utf8)
        let literal = String(data: json, encoding: .utf8) ?? "{}"

        var bridge = ""
        if let url = Bundle.main.url(forResource: "bridge", withExtension: "js"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            bridge = text
        }
        return "window.__NEL_INIT = " + literal + ";\n" + bridge
    }

    // MARK: 화면 → 앱 메시지

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let type = body["t"] as? String else {
            return
        }
        switch type {
        case "save":
            if let value = body["v"] as? String {
                store.writeText("dojang.json", value)
            }
        case "bg":
            if let slot = body["slot"] as? String, slot == "home" || slot == "cat",
               let value = body["v"] as? String {
                store.writeText("bg_" + slot + ".txt", value)
            }
        case "pref":
            if let key = body["k"] as? String, let value = body["v"] as? String {
                store.setPref(key, value)
            }
        case "copy":
            if let value = body["v"] as? String {
                UIPasteboard.general.string = value
            }
        case "share":
            if let value = body["v"] as? String {
                share(value)
            }
        default:
            break
        }
    }

    private func share(_ text: String) {
        let sheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        present(sheet, animated: true)
    }

    // MARK: 다크 모드와 화면 엔진 복구

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard started, previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }
        let theme = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        webView.evaluateJavaScript("document.documentElement.setAttribute('data-theme','" + theme + "')",
                                   completionHandler: nil)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadPage()
    }
}
