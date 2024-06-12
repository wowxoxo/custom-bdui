import UIKit

class CustomBDUI {
    func loadLocalData(jsonData: Data, in containerView: UIView) {
        let parser = JSONParser()
        do {
            let component = try parser.parse(json: jsonData)
            let serverDrivenView = ServerDrivenView()
            serverDrivenView.render(component: component, in: containerView)
        } catch {
            showError(in: containerView)
        }
    }

    func loadFromNetwork(urlString: String, method: String = "GET", requestData: Data? = nil, in containerView: UIView) {
            guard let url = URL(string: urlString) else {
                showError(in: containerView)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            if let data = requestData {
                request.httpBody = data
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data {
                        self.loadLocalData(jsonData: data, in: containerView)
                    } else {
                        self.showError(in: containerView)
                    }
                }
            }
            task.resume()
        }

    private func showError(in containerView: UIView) {
        let label = UILabel()
        label.text = "An error occurred."
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
