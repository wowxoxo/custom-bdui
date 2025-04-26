import UIKit

extension UIViewController {
    private static let spinnerTag = 999

    func showLoading(in containerView: UIView) {
        let loadingContainer = UIView()
        loadingContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingContainer)

        let imageView = UIImageView(image: UIImage(named: "time"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.text = "Загрузка данных"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(titleLabel)

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tag = Self.spinnerTag
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.addSubview(spinner)
        spinner.startAnimating()

        NSLayoutConstraint.activate([
            loadingContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            imageView.topAnchor.constraint(equalTo: loadingContainer.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor),

            spinner.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            spinner.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            spinner.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor)
        ])
    }

    func hideLoading(in containerView: UIView) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
    }

    func showError(
        in containerView: UIView,
        error: Error?,
        urlString: String,
        method: String,
        requestData: Data?,
        retryHandler: @escaping () -> Void
    ) {
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
        retryButton.addTarget(self, action: #selector(retryTapped(_:)), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(retryButton)
        
        // Store the retry handler in the button's associated object
        objc_setAssociatedObject(retryButton, &retryHandlerKey, retryHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 40), // Use safeAreaLayoutGuide
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

    @objc private func retryTapped(_ sender: UIButton) {
        if let retryHandler = objc_getAssociatedObject(sender, &retryHandlerKey) as? () -> Void {
            retryHandler()
        }
    }
}

// Associated object key for storing the retry handler
private var retryHandlerKey: UInt8 = 0
