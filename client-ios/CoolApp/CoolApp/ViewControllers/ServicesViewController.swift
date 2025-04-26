import UIKit

class ServicesViewController: UIViewController {
    private var renderer: BDUIRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Доступные услуги"
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated: false) // Hide back button

        renderer = BDUIRenderer()
        
        // Fetch the current state from the backend
        fetchCurrentState()
    }

    // Function to fetch the current state from the backend
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

        let body: [String: Any] = ["user_id": "test_user"]
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("js", json)
                        guard let screen = json["screen"] as? [String: Any] else {
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
                        print("screen is ok")
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

    // Function to handle events and send them to the backend
    private func handleEvent(action: String, event: String?) {
        guard let event = event else {
            print("No event provided")
            return
        }

        sendToBackend(event: event)
    }

    // Function to send events to the backend
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

        let body: [String: Any] = ["user_id": "test_user", "event": event]
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Event response JSON:", json)
                        guard let screen = json["screen"] as? [String: Any] else {
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
                        self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
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
