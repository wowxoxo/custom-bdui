import UIKit

class ContainerNode {
    func render(component: Component, in parentView: UIView, using nodeRenderer: NodeRenderer) {
        let containerView = ContainerNode.createContainerView(properties: component.properties)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        if let stackView = parentView as? UIStackView {
            stackView.addArrangedSubview(containerView)
        } else {
            parentView.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: parentView.topAnchor)
            ])
        }

        component.children?.forEach { child in
            nodeRenderer.render(component: child, in: containerView)
        }
    }

    static func createContainerView(properties: [String: Any]) -> UIStackView {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        if let orientation = properties["orientation"] as? String {
            containerView.axis = orientation == "vertical" ? .vertical : .horizontal
        }
        if let padding = properties["padding"] as? CGFloat {
            containerView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            containerView.isLayoutMarginsRelativeArrangement = true
        }
        return containerView
    }
}
