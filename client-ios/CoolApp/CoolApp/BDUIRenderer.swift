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

        // Track the button that needs to be bottom-aligned, along with its properties
        var bottomAlignedButton: UIButton?
        var bottomAlignedButtonProperties: (fullWidth: Bool, marginLeft: CGFloat, marginRight: CGFloat, width: CGFloat)?

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
                // Declare padding variables first
                let buttonPadding = CGFloat(properties["padding"] as? Int ?? 0)
                let buttonPaddingTop = CGFloat(properties["paddingTop"] as? Int ?? (properties["padding"] as? Int ?? 0))
                let buttonPaddingBottom = CGFloat(properties["paddingBottom"] as? Int ?? (properties["padding"] as? Int ?? 0))
                let buttonPaddingLeft = CGFloat(properties["paddingLeft"] as? Int ?? (properties["padding"] as? Int ?? 0))
                let buttonPaddingRight = CGFloat(properties["paddingRight"] as? Int ?? (properties["padding"] as? Int ?? 0))

                // Create the button configuration
                var buttonConfig = UIButton.Configuration.plain()
                buttonConfig.contentInsets = NSDirectionalEdgeInsets(
                    top: buttonPaddingTop,
                    leading: buttonPaddingLeft,
                    bottom: buttonPaddingBottom,
                    trailing: buttonPaddingRight
                )

                // Create the button
                let button = UIButton(configuration: buttonConfig)

                // Load image if imageUri is provided
                if let imageUri = properties["imageUri"] as? String, let url = URL(string: imageUri) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            print("Error loading button image: \(error.localizedDescription)")
                            return
                        }
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                var updatedConfig = button.configuration ?? UIButton.Configuration.plain()
                                updatedConfig.image = image
                                updatedConfig.imagePlacement = .all
                                updatedConfig.contentInsets = NSDirectionalEdgeInsets(
                                    top: buttonPaddingTop,
                                    leading: buttonPaddingLeft,
                                    bottom: buttonPaddingBottom,
                                    trailing: buttonPaddingRight
                                )
                                button.configuration = updatedConfig
                            }
                        }
                    }.resume()
                } else {
                    buttonConfig.title = properties["text"] as? String
                    buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                        var outgoing = incoming
                        outgoing.font = .systemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 18))
                        outgoing.foregroundColor = UIColor(hex: properties["color"] as? String ?? "#1E90FF")
                        return outgoing
                    }
                    button.configuration = buttonConfig
                }

                // Apply background color
                if let backgroundColor = properties["backgroundColor"] as? String {
                    button.backgroundColor = UIColor(hex: backgroundColor)
                }

                // Apply border radius
                if let borderRadius = properties["borderRadius"] as? Int {
                    button.layer.cornerRadius = CGFloat(borderRadius)
                    button.clipsToBounds = true
                }

                let action = properties["action"] as? String
                let event = properties["event"] as? String
                let target = properties["target"] as? String
                button.addAction(UIAction { _ in
                    if action == "toggle", let target = target, let targetView = self.viewMap[target] as? UIButton {
                        targetView.isEnabled.toggle()
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
                let fullWidth = properties["fullWidth"] as? Bool ?? false
                let marginLeft = CGFloat(properties["marginLeft"] as? Int ?? 0)
                let marginRight = CGFloat(properties["marginRight"] as? Int ?? 0)
                let width = CGFloat(properties["width"] as? Int ?? 200)

                if bottomAligned && container === self.view {
                    bottomAlignedButton = button
                    // Store properties for the bottom-aligned button
                    bottomAlignedButtonProperties = (fullWidth: fullWidth, marginLeft: marginLeft, marginRight: marginRight, width: width)
                } else {
                    if paddingTop > 0 {
                        let spacer = UIView()
                        stackView.addArrangedSubview(spacer)
                        spacer.heightAnchor.constraint(equalToConstant: paddingTop).isActive = true
                    }

                    // Wrap the button in a container to apply margins
                    let buttonContainer = UIView()
                    buttonContainer.translatesAutoresizingMaskIntoConstraints = false
                    buttonContainer.addSubview(button)
                    stackView.addArrangedSubview(buttonContainer)

                    if fullWidth {
                        // Stretch the button to fill the container width, minus margins
                        NSLayoutConstraint.activate([
                            button.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
                            button.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
                            button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
                            button.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
                            buttonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: marginLeft),
                            buttonContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -marginRight)
                        ])
                    } else {
                        // Center the button with a fixed width
                        NSLayoutConstraint.activate([
                            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
                            button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
                            button.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
                            button.widthAnchor.constraint(equalToConstant: width),
                            buttonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: marginLeft),
                            buttonContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -marginRight)
                        ])
                    }
                }

            case "image":
                let imageView = UIImageView()
                imageView.backgroundColor = .lightGray // Visual placeholder while loading
                if let uri = properties["uri"] as? String, let url = URL(string: uri) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                imageView.backgroundColor = .red // Indicate failure
                            }
                            return
                        }
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                imageView.image = image
                                imageView.backgroundColor = nil // Clear placeholder
                            }
                        }
                    }.resume()
                } else {
                    print("Invalid image URI: \(properties["uri"] ?? "none")")
                    imageView.backgroundColor = .red // Indicate invalid URI
                }
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false

                // Handle margins
                let marginTop = CGFloat(properties["marginTop"] as? Int ?? 0)
                let marginBottom = CGFloat(properties["marginBottom"] as? Int ?? 0)
                let marginLeft = CGFloat(properties["marginLeft"] as? Int ?? 0)
                let marginRight = CGFloat(properties["marginRight"] as? Int ?? 0)

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)

                // Add top margin/padding
                if marginTop > 0 || paddingTop > 0 {
                    let spacer = UIView()
                    stackView.addArrangedSubview(spacer)
                    spacer.heightAnchor.constraint(equalToConstant: marginTop + paddingTop).isActive = true
                }

                // Wrap the image view in a container to apply horizontal margins
                let imageContainer = UIView()
                imageContainer.translatesAutoresizingMaskIntoConstraints = false
                imageContainer.addSubview(imageView)
                stackView.addArrangedSubview(imageContainer)

                let width = CGFloat(properties["width"] as? Int ?? 100)
                let height = CGFloat(properties["height"] as? Int ?? 50)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
                    imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: width),
                    imageView.heightAnchor.constraint(equalToConstant: height),
                    imageContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: marginLeft),
                    imageContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -marginRight)
                ])

                // Add bottom margin
                if marginBottom > 0 {
                    let spacer = UIView()
                    stackView.addArrangedSubview(spacer)
                    spacer.heightAnchor.constraint(equalToConstant: marginBottom).isActive = true
                }

            default:
                break
            }
        }

        // Handle bottom-aligned button
        if let button = bottomAlignedButton, let props = bottomAlignedButtonProperties {
            // Remove the button from the stack view if it was added
            stackView.arrangedSubviews.first(where: { $0 === button })?.removeFromSuperview()
            
            // Add the button directly to the container and pin to the bottom
            container.addSubview(button)
            
            if props.fullWidth {
                // Stretch the button to fill the container width, minus margins
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: props.marginLeft),
                    button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -props.marginRight),
                    button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                ])
            } else {
                // Center the button with a fixed width
                NSLayoutConstraint.activate([
                    button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                    button.widthAnchor.constraint(equalToConstant: props.width)
                ])
            }

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
