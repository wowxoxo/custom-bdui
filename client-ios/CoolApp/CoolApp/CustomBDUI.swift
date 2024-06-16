import UIKit

class CustomBDUI {
    private var originalRequestParams: (urlString: String, method: String, requestData: Data?, containerView: UIView)?

    func testLoadLocalData(jsonData: Data, in containerView: UIView) {
        let parser = JSONParser()
        do {
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
            showError(in: containerView, error: error, urlString: "", method: "GET", requestData: nil)
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
            showError(in: containerView, error: error, urlString: "", method: "GET", requestData: nil)
        }
    }

    func loadFromNetwork(urlString: String, method: String = "GET", requestData: Data? = nil, in containerView: UIView) {
        guard let url = URL(string: urlString) else {
            showError(in: containerView, error: nil, urlString: urlString, method: method, requestData: requestData)
            return
        }

        showLoading(in: containerView)

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let data = requestData {
            request.httpBody = data
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.hideLoading(in: containerView)
                if let data = data {
                    self.loadLocalData(jsonData: data, in: containerView)
                } else {
                    self.showError(in: containerView, error: error, urlString: urlString, method: method, requestData: requestData)
                }
            }
        }
        task.resume()
    }

    private func showLoading(in containerView: UIView) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tag = 999 // Arbitrary number to identify the spinner later
        spinner.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spinner)
        spinner.startAnimating()

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    private func hideLoading(in containerView: UIView) {
        if let spinner = containerView.viewWithTag(999) as? UIActivityIndicatorView {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }

    private func showError(in containerView: UIView, error: Error?, urlString: String, method: String, requestData: Data?) {
        self.originalRequestParams = (urlString: urlString, method: method, requestData: requestData, containerView: containerView)

        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(image: UIImage(named: "error_cat"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Что-то пошло не так"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Попробуйте снова или зайдите позже"
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Повторить", for: .normal)
        retryButton.setTitleColor(.blue, for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(retryButton)
        
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
        if let params = originalRequestParams {
            loadFromNetwork(urlString: params.urlString, method: params.method, requestData: params.requestData, in: params.containerView)
        }
    }
}
