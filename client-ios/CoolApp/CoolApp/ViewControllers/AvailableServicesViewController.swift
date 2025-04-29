import UIKit

class AvailableServicesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let startDemoButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Демо"

        setupUI()
        animateUI()
    }

    private func setupUI() {
        // Logo Image
        logoImageView.image = UIImage(named: "CoolAppLogo") // Replace with your asset
        if logoImageView.image == nil {
            logoImageView.backgroundColor = .lightGray // Fallback if image is missing
        }
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        // Title
        titleLabel.text = "Добро пожаловать в CoolApp"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Попробуйте демо-версию приложения и откройте новые возможности"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Start Demo Button
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "Начать демо"
        buttonConfig.baseBackgroundColor = UIColor(hex: "#007AFF") // System blue
        buttonConfig.baseForegroundColor = .white
        buttonConfig.cornerStyle = .medium
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 18, weight: .medium)
            return outgoing
        }
        startDemoButton.configuration = buttonConfig
        startDemoButton.translatesAutoresizingMaskIntoConstraints = false
        startDemoButton.addTarget(self, action: #selector(startDemoTapped), for: .touchUpInside)
        view.addSubview(startDemoButton)

        // Layout Constraints
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            startDemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startDemoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startDemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startDemoButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func animateUI() {
        // Initial states for animation
        logoImageView.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        startDemoButton.alpha = 0
        startDemoButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        // Fade in elements with a slight delay
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
            self.logoImageView.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut) {
            self.titleLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseInOut) {
            self.subtitleLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseInOut) {
            self.startDemoButton.alpha = 1
            self.startDemoButton.transform = CGAffineTransform.identity
        }
    }

    @objc private func startDemoTapped() {
        // Animate button tap
        UIView.animate(withDuration: 0.1, animations: {
            self.startDemoButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.startDemoButton.transform = CGAffineTransform.identity
            }
            // Navigate to NeedRegisterViewController
            self.performSegue(withIdentifier: "toNeedRegister", sender: nil)
        }
    }
}
