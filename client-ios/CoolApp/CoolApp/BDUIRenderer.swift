import UIKit

class BDUIRenderer {
    private var viewMap: [String: UIView] = [:] // Track views by target
    private var eventHandler: ((String, String?) -> Void)?
    private var view: UIView?
    private var rootContainer: UIView? // Add this to track the root container
    
    private struct AssociatedKeys {
        static var telNumber = "telNumber"
    }

    @objc private func handleTelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let tel = objc_getAssociatedObject(label, &AssociatedKeys.telNumber) as? String,
              let url = URL(string: "tel://\(tel)") else { return }

        let alert = UIAlertController(
            title: "Позвонить",
            message: label.text,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Позвонить", style: .default) { _ in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        // Present the alert (need access to the view controller)
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            // Traverse the view controller hierarchy to find the topmost presented controller
            var topController = viewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }

    func render(json: [String: Any], into container: UIView, eventHandler: @escaping (String, String?) -> Void) {
        self.eventHandler = eventHandler
        self.view = container
        self.viewMap.removeAll()
        
        if self.rootContainer == nil {
            self.rootContainer = container
        }

        // Clear existing subviews
        container.subviews.forEach { $0.removeFromSuperview() }

        guard let components = json["components"] as? [[String: Any]] else { return }

        var lastView: UIView?

        for component in components {
            guard let type = component["type"] as? String,
                  let properties = component["properties"] as? [String: Any] else { continue }

            switch type {
            case "container":
                let padding = CGFloat(properties["padding"] as? Int ?? 0)
                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let subContainer = UIView()
                if let hex = properties["backgroundColor"] as? String {
                    subContainer.backgroundColor = UIColor(hex: hex)
                }
                subContainer.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(subContainer)

                // Render children into the subContainer
                if let children = component["children"] as? [[String: Any]] {
                    render(json: ["components": children], into: subContainer, eventHandler: eventHandler)
                }

                // Anchor the subContainer to the previous view (or container top) and apply padding
                let topAnchor = lastView?.bottomAnchor ?? (container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor)
                NSLayoutConstraint.activate([
                    subContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
                    subContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
                    subContainer.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop)
                ])

                lastView = subContainer

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
                container.addSubview(label)

                // Make the label tappable if it has a "tel" action
                if let action = properties["action"] as? String, action == "tel" {
                    label.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTelTap(_:)))
                    label.addGestureRecognizer(tapGesture)
                    if let tel = properties["tel"] as? String {
                        objc_setAssociatedObject(label, &AssociatedKeys.telNumber, tel, .OBJC_ASSOCIATION_RETAIN)
                    }
                }

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let topAnchor = lastView?.bottomAnchor ?? (container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                    label.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop)
                ])

                lastView = label

            case "button":
                var buttonConfig = UIButton.Configuration.filled()
                buttonConfig.title = properties["text"] as? String
                buttonConfig.baseForegroundColor = UIColor(hex: properties["color"] as? String ?? "#1E90FF")
                buttonConfig.baseBackgroundColor = UIColor(hex: properties["backgroundColor"] as? String ?? "#1E90FF")
                buttonConfig.cornerStyle = .medium
                buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 18))
                    return outgoing
                }

                let button = UIButton(configuration: buttonConfig)
                button.isEnabled = !(properties["disabled"] as? Bool ?? false)
//                button.alpha = button.isEnabled ? 1.0 : 0.5
                let action = properties["action"] as? String
                let event = properties["event"] as? String
                let target = properties["target"] as? String
                button.addAction(UIAction { [weak self] _ in
                    if action == "toggle", let target = target, let targetView = self?.viewMap[target] as? UIButton {
                        targetView.isEnabled.toggle()
                    } else if action == "request", let event = event {
                        eventHandler(action!, event)
                    } else if action == "webview" {
                        eventHandler(action!, properties["uri"] as? String)
                    }
                }, for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false

                // Add the button to the rootContainer if bottomAligned, otherwise to the current container
                let isBottomAligned = properties["bottomAligned"] as? Bool ?? false
                let parentContainer = isBottomAligned ? (self.rootContainer ?? container) : container
                parentContainer.addSubview(button)

                if let target = target {
                    self.viewMap[target] = button
                }

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)

                if isBottomAligned {
                    // Pin the button to the bottom of the root container
                    let bottomAnchor = parentContainer.safeAreaLayoutGuide.bottomAnchor
                    NSLayoutConstraint.activate([
                        button.leadingAnchor.constraint(equalTo: parentContainer.leadingAnchor, constant: 20),
                        button.trailingAnchor.constraint(equalTo: parentContainer.trailingAnchor, constant: -20),
                        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                        button.heightAnchor.constraint(equalToConstant: 50)
                    ])
                } else {
                    // Stack the button as part of the normal flow
                    let topAnchor = lastView?.bottomAnchor ?? (container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor)
                    NSLayoutConstraint.activate([
                        button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                        button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                        button.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
                        button.heightAnchor.constraint(equalToConstant: 50)
                    ])
                    lastView = button
                }

            case "image":
                let imageView = UIImageView()
                if let uri = properties["uri"] as? String, let url = URL(string: uri) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                imageView.image = image
                            }
                        }
                    }.resume()
                }
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)

                let width = CGFloat(properties["width"] as? Int ?? 100)
                let height = CGFloat(properties["height"] as? Int ?? 50)
                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let marginBottom = CGFloat(properties["marginBottom"] as? Int ?? 0)
                let topAnchor = lastView?.bottomAnchor ?? (container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    imageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop + marginBottom),
                    imageView.widthAnchor.constraint(equalToConstant: width),
                    imageView.heightAnchor.constraint(equalToConstant: height)
                ])

                lastView = imageView

            case "checkbox":
                let checkbox = UIButton(type: .system)
                let isChecked = properties["checked"] as? Bool ?? false
                checkbox.setImage(UIImage(systemName: isChecked ? "checkmark.square" : "square"), for: .normal)
                checkbox.tintColor = UIColor(hex: properties["color"] as? String ?? "#000000")
                let label = UILabel()
                label.text = properties["label"] as? String
                label.font = .systemFont(ofSize: CGFloat(properties["font_size"] as? Int ?? 14))
                label.textColor = .black
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false

                let stack = UIStackView(arrangedSubviews: [checkbox, label])
                stack.axis = .horizontal
                stack.spacing = 8
                stack.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(stack)

                checkbox.addAction(UIAction { [weak self] _ in
                    let isChecked = checkbox.image(for: .normal) == UIImage(systemName: "checkmark.square")
                    checkbox.setImage(UIImage(systemName: isChecked ? "square" : "checkmark.square"), for: .normal)

                    if let action = properties["action"] as? String, action == "toggle",
                       let target = properties["target"] as? String,
                       let targetView = self?.viewMap[target] as? UIButton {
                        targetView.isEnabled = !isChecked
                    } else if let event = properties["event"] as? String {
                        self?.eventHandler?("request", event)
                    }
                }, for: .touchUpInside)

//                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let paddingTop = 0
                let topAnchor = lastView?.bottomAnchor ?? (container === self.view ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor)
                NSLayoutConstraint.activate([
                    stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                    stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                    stack.topAnchor.constraint(equalTo: topAnchor, constant: 0)
                ])

                lastView = stack

            default:
                break
            }
        }

        // Ensure the last view doesn't stretch beyond the container's bottom
        if let lastView = lastView {
            let bottomAnchor = container === self.view ? container.safeAreaLayoutGuide.bottomAnchor : container.bottomAnchor
            NSLayoutConstraint.activate([
                lastView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
            ])
        }
    }

//    private var view: UIView?


}

//private struct AssociatedKeys {
//    static var telNumber = "telNumber"
//}

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

//extension NSTextAlignment {
//    init(from string: String) {
//        switch string.lowercased() {
//        case "center": return .center
//        case "right": return .right
//        default: return .left
//        }
//    }
//}

