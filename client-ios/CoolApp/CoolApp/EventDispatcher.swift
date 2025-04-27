import UIKit

class EventDispatcher {
    static func sendEvent(
        flow: String,
        event: String,
        viewController: UIViewController,
        onSuccess: @escaping ([String: Any]?) -> Void,
        onError: @escaping (Error?) -> Void
    ) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/next") else {
            onError(nil)
            return
        }

        viewController.showLoading(in: viewController.view)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": "test_user", "flow": flow, "event": event]
        let requestData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = requestData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                viewController.hideLoading(in: viewController.view)

                if let error = error {
                    onError(error)
                    return
                }

                guard let data = data else {
                    onError(nil)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        onSuccess(json)
                    } else {
                        onError(nil)
                    }
                } catch {
                    onError(error)
                }
            }
        }.resume()
    }

    static func fetchCurrentState(
        flow: String,
        viewController: UIViewController,
        onSuccess: @escaping ([String: Any]?) -> Void,
        onError: @escaping (Error?) -> Void
    ) {
        guard let url = URL(string: "http://127.0.0.1:8000/bdui-dsl/fsm/current") else {
            onError(nil)
            return
        }

        viewController.showLoading(in: viewController.view)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": "test_user", "flow": flow]
        let requestData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = requestData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                viewController.hideLoading(in: viewController.view)

                if let error = error {
                    onError(error)
                    return
                }

                guard let data = data else {
                    onError(nil)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        onSuccess(json)
                    } else {
                        onError(nil)
                    }
                } catch {
                    onError(error)
                }
            }
        }.resume()
    }
}
