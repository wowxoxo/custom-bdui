import UIKit

class ImageNode {
    func render(component: Component, in parentView: UIView) {
        let imageView = createImageView(properties: component.properties)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func createImageView(properties: [String: Any]) -> UIImageView {
        let imageView = UIImageView()
        if let urlString = properties["imageUrl"] as? String,
           let url = URL(string: urlString),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            imageView.image = image
        }
        return imageView
    }
}
