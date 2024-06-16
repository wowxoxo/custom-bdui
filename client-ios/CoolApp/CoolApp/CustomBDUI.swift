import UIKit

class CustomBDUI {
    func loadLocalData(jsonData: Data, in containerView: UIView) {
            let parser = JSONParser()
            do {
                // Use a simple hardcoded JSON for testing
                let simpleJsonString = """
                {
                    "screen": {
                        "id": "test_screen",
                        "components": [
                            {
                                "type": "text",
                                "properties": {
                                    "text": "Test Text",
                                    "font_size": 24,
                                    "color": "#000000",
                                    "alignment": "center"
                                }
                            }
                        ]
                    }
                }
                """
                let simpleJsonData = simpleJsonString.data(using: .utf8)!
                let components = try parser.parse(json: simpleJsonData)
                
                let serverDrivenView = ServerDrivenView()
                for component in components {
                    serverDrivenView.render(component: component, in: containerView)
                }
            } catch {
                showError(in: containerView, error: error)
            }
        }
    
    func loadLocalData0(jsonData: Data, in containerView: UIView) {
        let parser = JSONParser()
        do {
            let components = try parser.parse(json: jsonData)
            let serverDrivenView = ServerDrivenView()
            for component in components {
                serverDrivenView.render(component: component, in: containerView)
            }
        } catch {
            showError(in: containerView, error: error)
        }
    }

    func loadFromNetwork(urlString: String, method: String = "GET", requestData: Data? = nil, in containerView: UIView) {
        guard let url = URL(string: urlString) else {
            showError(in: containerView, error: nil)
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
                    self.showError(in: containerView, error: error)
                }
            }
        }
        task.resume()
    }

    private func showError(in containerView: UIView, error: Error?) {
        let label = UILabel()
        label.text = "An error occurred: \(error?.localizedDescription ?? "Unknown error")"
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }
}
