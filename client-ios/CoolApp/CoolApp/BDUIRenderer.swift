import UIKit

class BDUIRenderer {
    private var viewMap: [String: UIView] = [:] // Track views by target
    weak var view: UIView? // Track the root view for safe area handling

    func render(json: [String: Any], into container: UIView, eventHandler: @escaping (String, String?) -> Void) {
        // Clear existing subviews
        container.subviews.forEach { $0.removeFromSuperview() }
        viewMap.removeAll()
        
        guard let components = json["components"] as? [[String: Any]] else { return }
        var lastView: UIView?

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
                container.addSubview(subContainer)

                if let children = component["children"] as? [[String: Any]] {
                    render(json: ["components": children], into: subContainer, eventHandler: eventHandler)
                }

                // Use safeAreaLayoutGuide for top-level containers
                let topAnchor = container === self.view ? container.safeAreaLayoutGuide.topAnchor : (lastView?.bottomAnchor ?? container.topAnchor)
                NSLayoutConstraint.activate([
                    subContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: paddingHorizontal),
                    subContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -paddingHorizontal),
                    subContainer.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop)
                ])

                if let bottomChild = subContainer.subviews.last {
                    NSLayoutConstraint.activate([
                        subContainer.bottomAnchor.constraint(equalTo: bottomChild.bottomAnchor, constant: paddingTop)
                    ])
                }

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

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let topAnchor = container === self.view ? container.safeAreaLayoutGuide.topAnchor : (lastView?.bottomAnchor ?? container.topAnchor)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                    label.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop)
                ])

                lastView = label

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
                    } else if action == "request", let event = event {
                        eventHandler(action!, event)
                    } else if action == "webview" {
                        eventHandler(action!, properties["uri"] as? String)
                    }
                }, for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(button)

                if let target = target {
                    viewMap[target] = button
                }

                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let bottomAligned = properties["bottomAligned"] as? Bool ?? false
                if bottomAligned && container === self.view {
                    NSLayoutConstraint.activate([
                        button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                        button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                        button.widthAnchor.constraint(equalToConstant: 200)
                    ])
                } else {
                    NSLayoutConstraint.activate([
                        button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                        button.topAnchor.constraint(equalTo: lastView?.bottomAnchor ?? container.topAnchor, constant: paddingTop),
                        button.widthAnchor.constraint(equalToConstant: 200)
                    ])
                }

                lastView = button

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
                container.addSubview(imageView)

                let width = CGFloat(properties["width"] as? Int ?? 100)
                let height = CGFloat(properties["height"] as? Int ?? 50)
                let paddingTop = CGFloat(properties["paddingTop"] as? Int ?? 0)
                let topAnchor = container === self.view ? container.safeAreaLayoutGuide.topAnchor : (lastView?.bottomAnchor ?? container.topAnchor)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    imageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
                    imageView.widthAnchor.constraint(equalToConstant: width),
                    imageView.heightAnchor.constraint(equalToConstant: height)
                ])

                lastView = imageView

            default:
                break
            }
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
