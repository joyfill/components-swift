//
//  ViewController.swift
//  JoyfillUIKitExample
//
//  Created by Vishnu Dutt on 02/04/24.
//

import UIKit
import JoyfillModel
import JoyfillAPIService

class RootViewController: UIViewController {
    private var apiService: APIService!

    override func viewDidLoad() {
        super.viewDidLoad()
        apiService = APIService(accessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk", baseURL: "https://api-joy.joyfill.io/v1")
        makeAPICallForSubmission("doc_67aae8855c37e8d41f0abbac")
    }

    private func makeAPICallForSubmission(_ identifier: String) {
        apiService.fetchJoyDoc(identifier: identifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            let document = JoyDoc(dictionary: dictionary)
                            let vc = FormContainerViewController(document: document)
                            vc.view.frame = self.view.bounds
                            self.view.addSubview(vc.view)
                            self.addChild(vc)
                        }

                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
