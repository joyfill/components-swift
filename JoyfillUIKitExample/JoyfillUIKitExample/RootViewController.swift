//
//  ViewController.swift
//  JoyfillUIKitExample
//
//  Created by Vishnu Dutt on 02/04/24.
//

import UIKit
import Joyfill
import JoyfillModel
import JoyfillAPIService

class RootViewController: UIViewController {
    private let apiService: APIService = APIService()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeAPICallForSubmission("doc_65fea61d883404c9b91dc30c")
    }

    private func makeAPICallForSubmission(_ identifier: String) {
        apiService.fetchJoyDoc(identifier: identifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let document = try JSONDecoder().decode(JoyDoc.self, from: data)
                        let vc = FormContainerViewController(document: document)
                        vc.view.frame = self.view.bounds
                        self.view.addSubview(vc.view)
                        self.addChild(vc)
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
