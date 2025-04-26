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
        fetchCurrentState { [weak self] json in
            guard let self = self, let json = json else {
                print("Failed to fetch or parse current state")
                return
            }
            // Render the UI using BDUIRenderer
            print("js", json)
            let screen = json["screen"] as? [String: Any]
            if screen != nil {
                print("screen is ok")
                self.renderer.render(json: screen!, into: self.view, eventHandler: self.handleEvent)
            } else {
                print("Error: Invalid server response")
                return
            }
        }
    }

    // Function to fetch the current state from the backend
    private func fetchCurrentState(completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/current") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add user_id to the request body (you may need to adjust this based on your app's user management)
        let body: [String: Any] = ["user_id": "test_user"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching current state: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        completion(json)
                    }
                } else {
                    print("Invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // Function to handle events and send them to the backend
    private func handleEvent(action: String, event: String?) {
        guard let event = event else {
            print("No event provided")
            return
        }

        sendToBackend(event: event) { [weak self] json in
            guard let self = self, let json = json else {
                print("Failed to handle event or parse response")
                return
            }
            // Re-render the UI with the new state
            self.renderer.render(json: json, into: self.view, eventHandler: self.handleEvent)
        }
    }

    // Function to send events to the backend
    private func sendToBackend(event: String, completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add user_id and event to the request body
        let body: [String: Any] = [
            "user_id": "default_user",
            "event": event
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending event to backend: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        completion(json)
                    }
                } else {
                    print("Invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
