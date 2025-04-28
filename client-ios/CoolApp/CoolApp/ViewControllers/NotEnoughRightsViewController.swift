import UIKit

class NotEnoughRightsViewController: UIViewController {
    private let renderer = BDUIRenderer()
    private var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Недостаточно прав"
        view.backgroundColor = .white

        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Pin the container view to the safe area
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        fetchUI()
    }

    private func fetchUI() {
        showLoading(in: containerView)

        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/current") else {
            showError(in: containerView, error: nil, urlString: "Invalid URL", method: "GET", requestData: nil) {
                self.fetchUI()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["user_id": "test_user", "screen_id": "not_enough_rights"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showError(in: self.containerView, error: error, urlString: url.absoluteString, method: "POST", requestData: request.httpBody) {
                        self.fetchUI()
                    }
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    self.showError(in: self.containerView, error: nil, urlString: url.absoluteString, method: "POST", requestData: request.httpBody) {
                        self.fetchUI()
                    }
                }
                return
            }

            DispatchQueue.main.async {
                self.hideLoading(in: self.containerView)
                self.renderUI(json: json)
            }
        }.resume()
    }

    private func renderUI(json: [String: Any]) {
        print("Fetched JSON: \(json)")
        
        renderer.render(json: json["screen"] as! [String : Any], into: containerView, eventHandler: { [weak self] action, event in
            guard let self = self else { return }

            if action == "request", let event = event {
                self.sendEventToBackend(event: event) { screenId in
                    if screenId == "registration.auth" {
                        DispatchQueue.main.async {
                            let vc = WebviewAuthViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        print("Unexpected screen: \(screenId ?? "none")")
                    }
                }
            }
        })
    }

    private func sendEventToBackend(event: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["user_id": "test_user", "event": event]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String {
                print("Next screen: \(screenId)")
                completion(screenId)
            } else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                completion(nil)
            }
        }.resume()
    }
}
