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
import Spine

enum FollowUpError: Error {
    case MissingParameter(String)
}

class FollowUpsManager: GTDataManager {
    
    let path = "follow_ups"
    
    override init() {
        super.init()
        serializer.registerResource(FollowUpResource.self)
    }
    
    func createSubscriber(params: [String: String]) -> Promise<Void>? {
        showNetworkingIndicator()
        
        if !validate(params: params) {
            let error = FollowUpError.MissingParameter("invalid params")
            
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating subscriber, invalid params."])
            return Promise(error: error)
        }
        
        let paramsData = try! self.serializer.serializeResources(createFollowUpResource(params: params))
        let paramsJSON = try! JSONSerialization.jsonObject(with: paramsData, options: []) as! [String: Any]
        
        return issuePOSTRequest(paramsJSON)
            .then { data -> Promise<Void> in
                return Promise(value: ())
            }
            .catch(execute: { error in
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating subscriber."])
            })
            .always {
                self.hideNetworkIndicator()
        }
    }
    
    private func validate(params: [String: String]) -> Bool {
        if params["email"] == nil {
            return false
        }
        
        if params["name"] == nil {
            return false
        }
        
        if params["destination_id"] == nil {
            return false
        }
        
        return true
    }
    
    private func createFollowUpResource(params: [String: String]) -> [FollowUpResource] {
        return [FollowUpResource(email: params["email"]!,
                                name: params["name"]!,
                                destination: params["destination_id"]!,
                                language: GTSettings.shared.primaryLanguageId!)]
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
    }

}
