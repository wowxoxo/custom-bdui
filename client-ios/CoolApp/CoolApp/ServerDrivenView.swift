import UIKit

class ServerDrivenView {
    let nodeRenderer = NodeRenderer()

    func render(component: Component, in containerView: UIView) {
        nodeRenderer.render(component: component, in: containerView)
    }
}
