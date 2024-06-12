//
//  ViewController.swift
//  CoolApp
//
//  Created by admin on 09.06.2024.
//

import UIKit

class AvailableServicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let services = ["Услуга № 1", "Услуга № 2"]

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ServiceCell")
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return services.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
            cell.textLabel?.text = services[indexPath.row]
            return cell
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Selected row at \(indexPath.row)")
            if indexPath.row == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let pointsViewController = storyboard.instantiateViewController(withIdentifier: "custom_bdui_points_view_controller") as? CustomBDUIPointsViewController {
                    print("Navigating to PointsViewController")
                    navigationController?.pushViewController(pointsViewController, animated: true)
//                    self.present(pointsViewController, animated: true, completion: nil)
                } else {
                    print("Failed to instantiate PointsViewController")
                }
            } else {
                print("Second card clicked")
                // Handle the second card click
            }
        }
    

}

