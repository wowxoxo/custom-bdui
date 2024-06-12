import UIKit

class NodeRenderer {
    func render(component: Component, in parentView: UIView) {
        switch component.type {
        case "container":
            let containerView = createContainerView(properties: component.properties)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(containerView)
            component.children?.forEach { child in
                render(component: child, in: containerView)
            }
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: parentView.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
        case "text":
            let label = createLabel(properties: component.properties)
            label.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                label.topAnchor.constraint(equalTo: parentView.topAnchor)
            ])
        case "image":
            let imageView = createImageView(properties: component.properties)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        default:
            break
        }
    }

    private func createContainerView(properties: [String: Any]) -> UIStackView {
        let containerView = UIStackView()
        if let orientation = properties["orientation"] as? String {
            containerView.axis = orientation == "vertical" ? .vertical : .horizontal
        }
        if let padding = properties["padding"] as? CGFloat {
            containerView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            containerView.isLayoutMarginsRelativeArrangement = true
        }
        if let margin = properties["margin"] as? [String: CGFloat] {
            if let bottom = margin["bottom"] {
                containerView.layoutMargins.bottom = bottom
            }
        }
        return containerView
    }

    private func createLabel(properties: [String: Any]) -> UILabel {
        let label = UILabel()
        if let text = properties["text"] as? String {
            label.text = text
        }
        if let fontSize = properties["font_size"] as? CGFloat {
            label.font = label.font.withSize(fontSize)
        }
        if let color = properties["color"] as? String {
            label.textColor = UIColor(hex: color)
        }
        if let alignment = properties["alignment"] as? String {
            label.textAlignment = alignment == "center" ? .center : .left
        }
        return label
    }

    private func createImageView(properties: [String: Any]) -> UIImageView {
        let imageView = UIImageView()
        if let urlString = properties["imageUrl"] as? String,
           let url = URL(string: urlString),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            imageView.image = image
        }
        return imageView
    }
}

// Extension to convert hex color string to UIColor
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
