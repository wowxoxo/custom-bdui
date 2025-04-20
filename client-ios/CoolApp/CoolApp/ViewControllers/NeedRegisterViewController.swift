import UIKit

class NeedRegisterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Регистрация"
        view.backgroundColor = .white

        sendEventToBackend(event: "reset") { _ in } // Reset FSM

        let label = UILabel()
        label.text = "Зарегистрируйтесь в приложении «CoolApp»"
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let subLabel = UILabel()
        subLabel.text = "Первичная регистрация необходима для работы в приложении"
        subLabel.font = .systemFont(ofSize: 16)
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subLabel)

        let button = UIButton(type: .system)
        button.setTitle("Зарегистрироваться", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            subLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc func registerTapped() {
        sendEventToBackend(event: "tap_register") { screenId in
            if screenId == "auth" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toWebviewAuth", sender: nil)
                }
            } else {
                print("Unexpected screen: \(screenId ?? "none")")
            }
        }
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
