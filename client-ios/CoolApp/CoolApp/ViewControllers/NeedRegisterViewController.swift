import UIKit

class NeedRegisterViewController: UIViewController {
    private let renderer = BDUIRenderer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Регистрация"
        view.backgroundColor = .white
        
        sendEventToBackend(event: "reset") { json in
            guard let json = json, let screen = json["screen"] as? [String: Any] else {
                print("Error: Invalid server response")
                return
            }
            DispatchQueue.main.async {
                self.renderer.render(json: screen, into: self.view) { action, value in
                    if action == "request", let event = value {
                        self.sendEventToBackend(event: event) { response in
                            if let response = response,
                               let screenDict = response["screen"] as? [String: Any],
                               let screenId = screenDict["id"] as? String,
                               screenId == "registration.auth" {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toWebviewAuth", sender: nil)
                                }
                            } else {
                                print("Error: Invalid response or screen ID")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func sendEventToBackend(event: String, completion: @escaping ([String: Any]?) -> Void) {
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
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String {
                    print("Next screen: \(screenId)")
                } else {
                    print("Next screen: none")
                }
                completion(json)
            } else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                completion(nil)
            }
        }.resume()
    }
}
