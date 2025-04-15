import UIKit
import WebKit

class WebviewAuthViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Авторизация"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: self, action: #selector(backTapped)
        )
        webView.navigationDelegate = self
        
        let url = URL(string: "https://wowxoxo.github.io/coolapp-auth-form")!
        webView.load(URLRequest(url: url))
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
