import UIKit

class TextNode {
    func render(component: Component, in parentView: UIView) {
        let label = createLabel(properties: component.properties)
        label.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(label)
        
        print("TextNode: Rendering text: \(label.text ?? "")")
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
    }

    private func createLabel(properties: [String: Any]) -> UILabel {
        let label = UILabel()
        
        if let text = properties["text"] as? String {
            label.text = text
            print("createLabel: Found text: \(text)")
        } else {
            print("createLabel: No text found in properties: \(properties)")
        }
        
        if let fontSize = properties["font_size"] as? CGFloat {
            label.font = label.font.withSize(fontSize)
            print("createLabel: Found fontSize: \(fontSize)")
        } else {
            print("createLabel: No fontSize found in properties")
        }
        
        if let color = properties["color"] as? String {
            label.textColor = UIColor(hex: color)
            print("createLabel: Found color: \(color)")
        } else {
            print("createLabel: No color found in properties")
        }
        
        if let alignment = properties["alignment"] as? String {
            label.textAlignment = alignment == "center" ? .center : .left
            print("createLabel: Found alignment: \(alignment)")
        } else {
            print("createLabel: No alignment found in properties")
        }
        
        return label
    }
}
