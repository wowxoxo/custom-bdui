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

        var top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0
        if let padding = properties["padding"] as? CGFloat {
            top = padding
            left = padding
            bottom = padding
            right = padding
        }
        if let paddingTop = properties["paddingTop"] as? CGFloat {
            top = paddingTop
        }
        if let paddingLeft = properties["paddingLeft"] as? CGFloat {
            left = paddingLeft
        }
        if let paddingBottom = properties["paddingBottom"] as? CGFloat {
            bottom = paddingBottom
        }
        if let paddingRight = properties["paddingRight"] as? CGFloat {
            right = paddingRight
        }
        containerView.layoutMargins = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.distribution = .fill
        containerView.alignment = .fill
        return containerView
    }
}
