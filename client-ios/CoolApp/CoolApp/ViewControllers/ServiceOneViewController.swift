import UIKit

class ServiceOneViewController: UIViewController {
    private var renderer: BDUIRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Услуга №1"
        view.backgroundColor = .white

        // Override back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: self, action: #selector(backTapped)
        )

        renderer = BDUIRenderer()
        fetchCurrentState()
    }

    @objc func backTapped() {
        sendToBackend(event: "back")
    }

    private func fetchCurrentState() {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/current") else {
            print("Invalid URL")
            showError(
                in: view,
                error: nil,
                urlString: "http://127.0.0.1:8000/bdui-dsl/fsm/current",
                method: "POST",
                requestData: nil,
                retryHandler: { [weak self] in self?.fetchCurrentState() }
            )
            return
        }

        showLoading(in: view)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": "test_user", "flow": "service-one"]
        let requestData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = requestData

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading(in: self.view)

                if let error = error {
                    self.showError(
                        in: self.view,
                        error: error,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.fetchCurrentState() }
                    )
                    return
                }

                guard let data = data else {
                    self.showError(
                        in: self.view,
                        error: nil,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.fetchCurrentState() }
                    )
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let screen = json["screen"] as? [String: Any] {
                        self.clearView()
                        self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
                    } else {
                        self.showError(
                            in: self.view,
                            error: nil,
                            urlString: url.absoluteString,
                            method: "POST",
                            requestData: requestData,
                            retryHandler: { [weak self] in self?.fetchCurrentState() }
                        )
                    }
                } catch {
                    self.showError(
                        in: self.view,
                        error: error,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.fetchCurrentState() }
                    )
                }
            }
        }.resume()
    }

    private func clearView() {
        view.subviews.forEach { $0.removeFromSuperview() }
    }

    private func handleEvent(action: String, event: String?) {
        guard let event = event else {
            print("No event provided")
            return
        }

        sendToBackend(event: event)
    }

    private func sendToBackend(event: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else {
            print("Invalid URL")
            showError(
                in: view,
                error: nil,
                urlString: "http://127.0.0.1:8000/bdui-dsl/fsm/next",
                method: "POST",
                requestData: nil,
                retryHandler: { [weak self] in self?.sendToBackend(event: event) }
            )
            return
        }

        showLoading(in: view)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": "test_user", "flow": "service-one", "event": event]
        let requestData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = requestData

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading(in: self.view)

                if let error = error {
                    self.showError(
                        in: self.view,
                        error: error,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.sendToBackend(event: event) }
                    )
                    return
                }

                guard let data = data else {
                    self.showError(
                        in: self.view,
                        error: nil,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.sendToBackend(event: event) }
                    )
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let screen = json["screen"] as? [String: Any],
                       let screenId = screen["id"] as? String {
                        if screenId == "services" {
                            // Exit to ServicesViewController
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.clearView()
                            self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
                        }
                    } else {
                        self.showError(
                            in: self.view,
                            error: nil,
                            urlString: url.absoluteString,
                            method: "POST",
                            requestData: requestData,
                            retryHandler: { [weak self] in self?.sendToBackend(event: event) }
                        )
                    }
                } catch {
                    self.showError(
                        in: self.view,
                        error: error,
                        urlString: url.absoluteString,
                        method: "POST",
                        requestData: requestData,
                        retryHandler: { [weak self] in self?.sendToBackend(event: event) }
                    )
                }
            }
        }.resume()
    }
}
