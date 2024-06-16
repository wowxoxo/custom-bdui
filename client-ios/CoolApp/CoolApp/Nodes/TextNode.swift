import UIKit

class TextNode {
    func render(component: Component, in parentView: UIView) {
        let label = createLabel(properties: component.properties)
        label.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(label)
        
        print("TextNode: Rendering text: \(label.text ?? "")")
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: parentView.topAnchor),
            // Optionally adjust the height constraint if needed
            // label.heightAnchor.constraint(equalToConstant: 30)
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
        
        if let fontSize = properties["font_size"] as? NSNumber {
            label.font = label.font.withSize(CGFloat(truncating: fontSize))
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
