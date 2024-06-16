import UIKit

class CustomBDUI {
    func testLoadLocalData(jsonData: Data, in containerView: UIView) {
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
                                    "color": "#ff0000",
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
    
    func loadLocalData(jsonData: Data, in containerView: UIView) {
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

    private func showErrorDebug(in containerView: UIView, error: Error?) {
        let label = UILabel()
        label.text = "An error occurred: \(error?.localizedDescription ?? "Unknown error")"
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0  // Enable multiline
        
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func showError(in containerView: UIView, error: Error?) {
        // Remove existing subviews
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Image view
        let imageView = UIImageView(image: UIImage(named: "error_cat"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Что-то пошло не так"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Попробуйте снова или зайдите позже"
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Retry button
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Повторить", for: .normal)
        retryButton.setTitleColor(.blue, for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(retryButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            retryButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }

    @objc private func retryButtonTapped() {
        // Implement the retry action
        print("Retry button tapped")
    }


}
