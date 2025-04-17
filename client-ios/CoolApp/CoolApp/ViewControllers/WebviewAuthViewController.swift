import UIKit
import WebKit

class WebviewAuthViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    func viewDidLoad0() {
        super.viewDidLoad()
        title = "Авторизация"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: self, action: #selector(backTapped)
        )
        webView.navigationDelegate = self
        
        let url = URL(string: "https://wowxoxo.github.io/coolapp-auth-form")!
        webView.load(URLRequest(url: url))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Авторизация"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: self, action: #selector(backTapped)
        )

        // Create config with JS and inline media enabled
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true

        // Create the webView with custom config
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.keyboardDismissMode = .interactive

        view.addSubview(webView)

        // Add constraints so it fills the screen
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let url = URL(string: "https://wowxoxo.github.io/coolapp-auth-form") {
            webView.load(URLRequest(url: url))
        }
    }

    @objc func backTapped() {
        // Later: Send to backend, for now just go back
        navigationController?.popViewController(animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "coolapp" {
            print("Callback received: \(url.absoluteString)")
            // Later: Parse and send to backend
            decisionHandler(.cancel)
            navigationController?.popViewController(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }
}
