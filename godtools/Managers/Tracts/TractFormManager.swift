//
//  TractFormManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit

class TractFormManager: TractManager {
    
    func postFromForm(path: String, params: [String: String]) -> Promise<Void>? {
        if let url = Config.shared().baseUrl?.appendingPathComponent(path) {
            showNetworkingIndicator()
            
            return issuePOSTRequest(url: url, params: params)
                .then { data -> Promise<Void> in
                    return Promise(value: ())
            }
        } else {
            return nil
        }
    }

}
