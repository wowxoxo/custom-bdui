import UIKit

class NodeRenderer {
    let containerNode = ContainerNode()
    let textNode = TextNode()
    let imageNode = ImageNode()

    func render(component: Component, in parentView: UIView) {
        print("NodeRenderer: Rendering component type: \(component.type)")
        switch component.type {
        case "container":
            containerNode.render(component: component, in: parentView, using: self)
        case "text":
            textNode.render(component: component, in: parentView)
        case "image":
            imageNode.render(component: component, in: parentView)
        default:
            print("NodeRenderer: Unknown component type: \(component.type)")
        }
    }
}
