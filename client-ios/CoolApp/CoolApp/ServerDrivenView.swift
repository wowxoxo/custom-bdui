import UIKit

class ServerDrivenView {
    func render(component: Component, in containerView: UIView) {
        print("ServerDrivenView: Rendering component: \(component.type)")
        let nodeRenderer = NodeRenderer()
        nodeRenderer.render(component: component, in: containerView)
    }
}
