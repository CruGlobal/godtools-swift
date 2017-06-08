//
//  FollowUpsManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit

class FollowUpsManager: GTDataManager {
    
    let path = "follow_ups"
    
    func createSubscriber(params: [String: String]) -> Promise<Void>? {
        showNetworkingIndicator()
        
        return issuePOSTRequest(params)
            .then { data -> Promise<Void> in
                return Promise(value: ())
        }
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
    }

}
