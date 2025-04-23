import UIKit

class BDUIRenderer {
    private var viewMap: [String: UIView] = [:] // Track views by target
    weak var view: UIView? // Track the root view for safe area handling

    func render(json: [String: Any], into container: UIView, eventHandler: @escaping (String, String?) -> Void) {
        // Store the root container
        self.view = container
        
        // Clear existing subviews
        container.subviews.forEach { $0.removeFromSuperview() }
        viewMap.removeAll()
        
        guard let components = json["components"] as? [[String: Any]] else { return }

        // Create a stack view for the root container
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)

        // Pin the stack view to the safe area
        let topAnchor = container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor
        let bottomAnchor = container === self.view ? container.safeAreaLayoutGuide.bottomAnchor : container.bottomAnchor
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Track the button that needs to be bottom-aligned
        var bottomAlignedButton: UIButton?

        for component in components {
            guard let type = component["type"] as? String,
                  let properties = component["properties"] as? [String: Any] else { continue }

            switch type {
            case "container":
                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let paddingHorizontal = CGFloat(properties["padding"] as? Int ?? 0)
                let subContainer = UIView()
                
                if let hex = properties["backgroundColor"] as? String {
                    subContainer.backgroundColor = UIColor(hex: hex)
                }
                subContainer.translatesAutoresizingMaskIntoConstraints = false
                
                // Add padding views if needed
                if paddingTop > 0 {
                    let spacer = UIView()
                    stackView.addArrangedSubview(spacer)
                    spacer.heightAnchor.constraint(equalToConstant: paddingTop).isActive = true
                }

                stackView.addArrangedSubview(subContainer)

                // Apply horizontal padding
                NSLayoutConstraint.activate([
                    subContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: paddingHorizontal),
                    subContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -paddingHorizontal)
                ])

                if let children = component["children"] as? [[String: Any]] {
                    render(json: ["components": children], into: subContainer, eventHandler: eventHandler)
                }

            case "text":
                let label = UILabel()
                label.text = properties["text"] as? String
                label.font = (properties["bold"] as? Bool ?? false) ?
                    .boldSystemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 14)) :
                    .systemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 14))
                label.textColor = UIColor(hex: properties["color"] as? String ?? "#000000")
                label.textAlignment = NSTextAlignment(from: properties["alignment"] as? String ?? "left")
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                if paddingTop > 0 {
                    let spacer = UIView()
                    stackView.addArrangedSubview(spacer)
                    spacer.heightAnchor.constraint(equalToConstant: paddingTop).isActive = true
                }

                stackView.addArrangedSubview(label)

                // Apply leading/trailing constraints directly to the label
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20)
                ])

            case "button":
                let button = UIButton(type: .system)
                button.setTitle(properties["text"] as? String, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 18))
                button.setTitleColor(UIColor(hex: properties["color"] as? String ?? "#1E90FF"), for: .normal)
                let action = properties["action"] as? String
                let event = properties["event"] as? String
                let target = properties["target"] as? String
                button.addAction(UIAction { _ in
                    if action == "toggle", let target = target, let targetView = self.viewMap[target] as? UIButton {
                        targetView.isEnabled.toggle()
//                        targetView.isActive.toggle()
                    } else if action == "request", let event = event {
                        eventHandler(action!, event)
                    } else if action == "webview" {
                        eventHandler(action!, properties["uri"] as? String)
                    }
                }, for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false

                if let target = target {
                    viewMap[target] = button
                }

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let bottomAligned = properties["bottomAligned"] as? Bool ?? false

                if bottomAligned && container === self.view {
                    // Store the button to pin it to the bottom later
                    bottomAlignedButton = button
                } else {
                    if paddingTop > 0 {
                        let spacer = UIView()
                        stackView.addArrangedSubview(spacer)
                        spacer.heightAnchor.constraint(equalToConstant: paddingTop).isActive = true
                    }
                    stackView.addArrangedSubview(button)

                    // Center the button horizontally
                    NSLayoutConstraint.activate([
                        button.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
                        button.widthAnchor.constraint(equalToConstant: 200)
                    ])
                }

            case "image":
                let imageView = UIImageView()
                if let uri = properties["uri"] as? String, let url = URL(string: uri) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                imageView.image = image
                            }
                        }
                    }.resume()
                } else {
                    print("Invalid image URI: \(properties["uri"] ?? "none")")
                }
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                if paddingTop > 0 {
                    let spacer = UIView()
                    stackView.addArrangedSubview(spacer)
                    spacer.heightAnchor.constraint(equalToConstant: paddingTop).isActive = true
                }

                stackView.addArrangedSubview(imageView)

                let width = CGFloat(properties["width"] as? Int ?? 100)
                let height = CGFloat(properties["height"] as? Int ?? 50)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: width),
                    imageView.heightAnchor.constraint(equalToConstant: height)
                ])

            default:
                break
            }
        }

        // Handle bottom-aligned button
        if let button = bottomAlignedButton {
            // Remove the button from the stack view if it was added
            stackView.arrangedSubviews.first(where: { $0 === button })?.removeFromSuperview()
            
            // Add the button directly to the container and pin to the bottom
            container.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                button.widthAnchor.constraint(equalToConstant: 200)
            ])

            // Add a spacer to the stack view to push other content up
            let spacer = UIView()
            stackView.addArrangedSubview(spacer)
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

extension NSTextAlignment {
    init(from string: String) {
        switch string.lowercased() {
        case "center":
            self = .center
        case "right":
            self = .right
        case "justified":
            self = .justified
        case "natural":
            self = .natural
        default:
            self = .left
        }
    }
}
