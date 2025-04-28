import UIKit
import MapKit

class ServiceOneViewController: UIViewController {
    private var renderer: BDUIRenderer!
    private var isRequestInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Услуга №1"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        renderer = BDUIRenderer()
        fetchCurrentState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentState()
    }

    @objc func backTapped() {
        if isRequestInProgress {
            return
        }
        sendToBackend(event: "back")
    }

    private func fetchCurrentState() {
        isRequestInProgress = true
        navigationItem.leftBarButtonItem?.isEnabled = false

        EventDispatcher.fetchCurrentState(
            flow: "service-one",
            viewController: self,
            onSuccess: { [weak self] json in
                guard let self = self, let json = json, let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String else { return }
                self.isRequestInProgress = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                
                print("screenId", screenId)
                if screenId == "service-one.exit" {
                    // Navigate back to ServicesViewController if service-one already in exit status
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.clearView()
                    self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                self.isRequestInProgress = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.showError(
                    in: self.view,
                    error: error,
                    urlString: "http://127.0.0.1:8000/bdui-dsl/fsm/current",
                    method: "POST",
                    requestData: nil,
                    retryHandler: { [weak self] in self?.fetchCurrentState() }
                )
            }
        )
    }

    private func clearView() {
        view.subviews.forEach { $0.removeFromSuperview() }
    }

    private func handleEvent(action: String, event: String?) {
        guard let event = event else {
            print("No event provided")
            return
        }

        if event == "continue-route" {
            let coordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Service Center"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        } else {
            sendToBackend(event: event)
        }
    }

    private func sendToBackend(event: String) {
        isRequestInProgress = true
        navigationItem.leftBarButtonItem?.isEnabled = false

        EventDispatcher.sendEvent(
            flow: "service-one",
            event: event,
            viewController: self,
            onSuccess: { [weak self] json in
                guard let self = self, let json = json, let screen = json["screen"] as? [String: Any], let screenId = screen["id"] as? String else {
                    self?.isRequestInProgress = false
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    return
                }
                self.isRequestInProgress = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                
                print("screenId", screenId)
                if screenId == "service-one.exit" {
                    // Navigate back to ServicesViewController
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.clearView()
                    self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                self.isRequestInProgress = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.showError(
                    in: self.view,
                    error: error,
                    urlString: "http://127.0.0.1:8000/bdui-dsl/fsm/next",
                    method: "POST",
                    requestData: nil,
                    retryHandler: { [weak self] in self?.sendToBackend(event: event) }
                )
            }
        )
    }
}
