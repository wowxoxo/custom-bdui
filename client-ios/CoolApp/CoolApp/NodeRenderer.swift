import UIKit

class NodeRenderer {
    let containerNode = ContainerNode()
    let textNode = TextNode()
    let imageNode = ImageNode()

    func render(component: Component, in parentView: UIView) {
        switch component.type {
        case "container":
            containerNode.render(component: component, in: parentView, using: self)
        case "text":
            textNode.render(component: component, in: parentView)
        case "image":
            imageNode.render(component: component, in: parentView)
        default:
            break
        }
    }
}
