import UIKit

class ServicesViewController: UIViewController {
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var service1Button: UIButton!
    private var service2Button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Доступные услуги"
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated: false) // Hide back button

        titleLabel = UILabel()
        titleLabel.text = "Доступные услуги"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        subtitleLabel = UILabel()
        subtitleLabel.text = "Выберите услугу для продолжения"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        service1Button = UIButton(type: .system)
        service1Button.setTitle("Услуга №1", for: .normal)
        service1Button.titleLabel?.font = .systemFont(ofSize: 18)
        service1Button.setTitleColor(.systemBlue, for: .normal)
        service1Button.addTarget(self, action: #selector(service1Tapped), for: .touchUpInside)
        service1Button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(service1Button)

        service2Button = UIButton(type: .system)
        service2Button.setTitle("Услуга №2", for: .normal)
        service2Button.titleLabel?.font = .systemFont(ofSize: 18)
        service2Button.setTitleColor(.systemBlue, for: .normal)
        service2Button.addTarget(self, action: #selector(service2Tapped), for: .touchUpInside)
        service2Button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(service2Button)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            service1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            service1Button.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            service1Button.widthAnchor.constraint(equalToConstant: 200),

            service2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            service2Button.topAnchor.constraint(equalTo: service1Button.bottomAnchor, constant: 10),
            service2Button.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc func service1Tapped() {
        print("Service 1 selected")
    }

    @objc func service2Tapped() {
        print("Service 2 selected")
    }
}
