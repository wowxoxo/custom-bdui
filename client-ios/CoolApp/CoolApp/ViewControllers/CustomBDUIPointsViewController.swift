//
//  PointsViewController.swift
//  CoolApp
//
//  Created by admin on 12.06.2024.
//

import UIKit

class CustomBDUIPointsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

        override func viewDidLoad() {
            super.viewDidLoad()
//            containerView = UIView()
            
//            containerView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(containerView)
//            print(containerView)
//            testJSONParsing()
//            NSLayoutConstraint.activate([
//                containerView.topAnchor.constraint(equalTo: view.topAnchor),
//                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//            ])
            
//                addTestButton()
            
            let customBDUI = CustomBDUI()
//            if let localJsonPath = Bundle.main.path(forResource: "points", ofType: "json"),
//               let localJsonData = try? Data(contentsOf: URL(fileURLWithPath: localJsonPath)) {
//                customBDUI.loadLocalData(jsonData: localJsonData, in: containerView)
//            }
            
//            if let localJsonPath = Bundle.main.path(forResource: "points", ofType: "json") {
//                        print("JSON file path: \(localJsonPath)")
//                        if let localJsonData = try? Data(contentsOf: URL(fileURLWithPath: localJsonPath)) {
//                            print("JSON file loaded successfully.")
//                            if let jsonString = String(data: localJsonData, encoding: .utf8) {
//                                print("JSON content: \(jsonString)")
//                            }
//                            customBDUI.loadLocalData(jsonData: localJsonData, in: containerView)
//                        } else {
//                            print("Failed to convert JSON file to Data.")
//                        }
//                    } else {
//                        print("Failed to find JSON file path.")
//                    }
            
            // Example usage with network URL
             customBDUI.loadFromNetwork(urlString: "http://127.0.0.1:3130/dev/bdui-custom/points/", in: containerView)
        }
    
    
    
    private func addTestButton() {
            let button = UIButton(type: .system)
            button.setTitle("Test Button", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            button.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        }
        
        @objc private func testButtonTapped() {
            print("Test button tapped!")
        }

}
