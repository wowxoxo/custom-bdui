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
            
            let customBDUI = CustomBDUI()
            // usage with local json data
//            if let localJsonPath = Bundle.main.path(forResource: "points", ofType: "json"),
//               let localJsonData = try? Data(contentsOf: URL(fileURLWithPath: localJsonPath)) {
//                customBDUI.loadLocalData(jsonData: localJsonData, in: containerView)
//            }
            
            // usage with network URL
            self.title = "Получение услуги"
             customBDUI.loadFromNetwork(urlString: "http://127.0.0.1:8000/bdui-dsl/points/1", in: containerView)
        }
}
