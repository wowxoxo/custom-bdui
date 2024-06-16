import UIKit

class ContainerNode {
    func render(component: Component, in parentView: UIView, using nodeRenderer: NodeRenderer) {
        let containerView = ContainerNode.createContainerView(properties: component.properties)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(containerView)
        print("Rendering container with children count: \(component.children?.count ?? 0)")
        component.children?.forEach { child in
            nodeRenderer.render(component: child, in: containerView)
        }
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: parentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    static func createContainerView(properties: [String: Any]) -> UIStackView {
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
}
