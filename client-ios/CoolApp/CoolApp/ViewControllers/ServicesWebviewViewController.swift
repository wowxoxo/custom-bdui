import UIKit
import WebKit

class ServicesWebviewViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var initialURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выбрать услугу"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.keyboardDismissMode = .interactive

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        guard let url = initialURL else {
            showError(
                in: view,
                error: nil,
                urlString: "N/A",
                method: "N/A",
                requestData: nil,
                retryHandler: { [weak self] in self?.navigationController?.popViewController(animated: true) }
            )
            return
        }

        webView.load(URLRequest(url: url))
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "coolapp", url.absoluteString.contains("service?event=") {
            let event = url.absoluteString.components(separatedBy: "event=").last ?? ""
            if event == "select_service1" {
                let vc = ServiceOneViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else if event == "select_service2" {
                print("Service 2 selected")
            } else if event == "select_service3" {
                print("Service 3 selected")
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
