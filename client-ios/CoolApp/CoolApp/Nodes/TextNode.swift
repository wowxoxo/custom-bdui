import UIKit

class TextNode {
    func render(component: Component, in parentView: UIView) {
        let label = createLabel(properties: component.properties)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        if let stackView = parentView as? UIStackView {
            stackView.addArrangedSubview(label)
        } else {
            parentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 10)
            ])
        }
    }

    private func createLabel(properties: [String: Any]) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // Enable multiline
        
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
}
