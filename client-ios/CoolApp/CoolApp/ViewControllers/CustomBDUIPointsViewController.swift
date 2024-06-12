//
//  PointsViewController.swift
//  CoolApp
//
//  Created by admin on 12.06.2024.
//

import UIKit

class CustomBDUIPointsViewController: UIViewController {

    var containerView: UIView!

        override func viewDidLoad() {
            super.viewDidLoad()
            containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            let customBDUI = CustomBDUI()
            // Example usage with local JSON
            if let localJsonPath = Bundle.main.path(forResource: "points", ofType: "json"),
               let localJsonData = try? Data(contentsOf: URL(fileURLWithPath: localJsonPath)) {
                customBDUI.loadLocalData(jsonData: localJsonData, in: containerView)
            }
            
            // Example usage with network URL
            // customBDUI.loadFromNetwork(urlString: "https://example.com/data.json", in: containerView)
        }

}
