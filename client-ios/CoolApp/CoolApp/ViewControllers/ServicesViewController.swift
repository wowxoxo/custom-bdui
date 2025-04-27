import UIKit

class ServicesViewController: UIViewController {
    private var renderer: BDUIRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Доступные услуги"
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated: false)

        renderer = BDUIRenderer()
        fetchCurrentState()
    }

    private func fetchCurrentState() {
        EventDispatcher.fetchCurrentState(
            flow: "registration",
            viewController: self,
            onSuccess: { [weak self] json in
                guard let self = self, let json = json, let screen = json["screen"] as? [String: Any] else { return }
                self.renderer.render(json: screen, into: self.view, eventHandler: self.handleEvent)
            },
            onError: { [weak self] error in
                guard let self = self else { return }
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

    private func handleEvent(action: String, value: String?) {
        if action == "request", let event = value {
            if event == "select_service1" {
                let vc = ServiceOneViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else if event == "select_service2" {
                print("Service 2 selected")
            }
        } else if action == "webview", let uri = value, let url = URL(string: uri) {
            let vc = ServicesWebviewViewController()
            vc.initialURL = url
            navigationController?.pushViewController(vc, animated: true)
        } else {
            print("Invalid webview action or missing URI")
            showError(
                in: view,
                error: nil,
                urlString: "N/A",
                method: "N/A",
                requestData: nil,
                retryHandler: { [weak self] in self?.fetchCurrentState() }
            )
        }
    }
}
