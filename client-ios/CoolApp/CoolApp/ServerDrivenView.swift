import UIKit

class ServerDrivenView {
    let renderNode = NodeRenderer()

    func render(component: Component, in containerView: UIView) {
        renderNode.render(component: component, in: containerView)
    }
}
