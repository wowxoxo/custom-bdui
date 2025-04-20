import UIKit

class NotEnoughRightsViewController: UIViewController {
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var retryButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Недостаточно прав"
        view.backgroundColor = .white

        titleLabel = UILabel()
        titleLabel.text = "Недостаточно прав" // From backend JSON
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        subtitleLabel = UILabel()
        subtitleLabel.text = "Невозможно продолжить работу" // From backend JSON
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        retryButton = UIButton(type: .system)
        retryButton.setTitle("Попробовать снова", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 18)
        retryButton.setTitleColor(.systemBlue, for: .normal)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            retryButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc func retryTapped() {
        sendEventToBackend(event: "tap_register") { success in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(
                        self.navigationController!.viewControllers.first(where: { $0 is NeedRegisterViewController })!,
                        animated: true
                    )
                }
            } else {
                print("Failed to retry registration")
            }
        }
    }

    private func sendEventToBackend(event: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else {
            completion(false)
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
                completion(screenId == "auth")
            } else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                completion(false)
            }
        }.resume()
    }
}
