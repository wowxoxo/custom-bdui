import UIKit
import WebKit

class WebviewAuthViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

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
        sendEventToBackend(event: "back")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "coolapp" {
            print("Callback received: \(url.absoluteString)")
            let event = url.query?.contains("status=success") == true ? "auth_success" :
                        url.query?.contains("status=not_enough_rights") == true ? "auth_fail" : ""
            sendEventToBackend(event: event)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func sendEventToBackend(event: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["user_id": "test_user", "event": event]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String {
                    // Later: Switch to screenId
                    print("Next screen: \(screenId)")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Error: \(error?.localizedDescription ?? "No data")")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }.resume()
    }
}
