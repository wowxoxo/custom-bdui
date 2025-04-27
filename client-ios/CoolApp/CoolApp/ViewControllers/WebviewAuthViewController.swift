import UIKit
import WebKit

class WebviewAuthViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Авторизация"
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

        if let url = URL(string: "https://wowxoxo.github.io/coolapp-auth-form") {
            webView.load(URLRequest(url: url))
        } else {
            showError(
                in: view,
                error: nil,
                urlString: "https://wowxoxo.github.io/coolapp-auth-form",
                method: "N/A",
                requestData: nil,
                retryHandler: { [weak self] in self?.navigationController?.popViewController(animated: true) }
            )
        }
    }

    @objc func backTapped() {
        sendEventToBackend(event: "back")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "coolapp" {
            print("Callback received: \(url.absoluteString)")
            let event = url.absoluteString.contains("status=success") ? "auth_success" :
                        url.absoluteString.contains("status=not_enough_rights") ? "auth_fail" : ""
            sendEventToBackend(event: event)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func sendEventToBackend(event: String) {
        EventDispatcher.sendEvent(
            flow: "registration",
            event: event,
            viewController: self,
            onSuccess: { [weak self] json in
                guard let self = self, let json = json, let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String else { return }
                if screenId == "registration.services" {
                    let vc = ServicesViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if screenId == "registration.not_enough_rights" {
                    let vc = NotEnoughRightsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if screenId == "registration.need_register" {
                    self.navigationController?.popViewController(animated: true)
                }
            },
            onError: { [weak self] error in
                self?.showError(
                    in: self?.view ?? UIView(),
                    error: error,
                    urlString: "http://127.0.0.1:8000/bdui-dsl/fsm/next",
                    method: "POST",
                    requestData: nil,
                    retryHandler: { [weak self] in self?.navigationController?.popViewController(animated: true) }
                )
            }
        )
    }
}
