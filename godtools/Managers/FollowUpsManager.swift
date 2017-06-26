//
//  FollowUpsManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit
import Crashlytics

class FollowUpsManager: GTDataManager {
    
    let path = "follow_ups"
    
    func createSubscriber(params: [String: String]) -> Promise<Void>? {
        showNetworkingIndicator()
        
        return issuePOSTRequest(params)
            .then { data -> Promise<Void> in
                self.hideNetworkIndicator()
                return Promise(value: ())
        }
            .catch(execute: { error in
                self.hideNetworkIndicator()
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating subscriber."])
            })
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
    }

}
