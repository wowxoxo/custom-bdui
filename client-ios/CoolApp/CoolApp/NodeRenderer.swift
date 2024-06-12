import UIKit

class NodeRenderer {
    func render(component: Component, in parentView: UIView) {
        switch component.type {
        case "container":
            let containerView = UIView()
            // Set container properties
            containerView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(containerView)
            component.children?.forEach { child in
                render(component: child, in: containerView)
            }
            // Add layout constraints or positioning logic for containerView
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: parentView.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
        case "text":
            let label = UILabel()
            // Set label properties
            if let text = component.properties["text"] as? String {
                label.text = text
            }
            label.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(label)
            // Add layout constraints or positioning logic for label
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ])
        case "image":
            let imageView = UIImageView()
            // Set image properties
            if let urlString = component.properties["imageUrl"] as? String,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                imageView.image = image
            }
            imageView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(imageView)
            // Add layout constraints or positioning logic for imageView
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        default:
            break
        }
    }
}
