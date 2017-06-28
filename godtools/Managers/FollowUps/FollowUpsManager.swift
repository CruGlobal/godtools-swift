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
            return validationError()
        }
        
        let jsonAPIResource = createFollowUpResource(params: params)
        let localFollowUp = FollowUp(jsonAPIFollowUp: jsonAPIResource)
        
        saveLocalCopy(localFollowUp)
        
        let paramsData = try! self.serializer.serializeResources([jsonAPIResource])
        let paramsJSON = try! JSONSerialization.jsonObject(with: paramsData, options: []) as! [String: Any]
        
        return issuePOSTRequest(paramsJSON)
            .then { data -> Promise<Void> in
                self.removeLocalCopy(localFollowUp)
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
        if params["email"]?.characters.count == 0 {
            return false
        }
        
        if params["name"]?.characters.count == 0  {
            return false
        }
        
        if params["destination_id"]?.characters.count == 0  {
            return false
        }
        
        return true
    }
    
    private func validationError() -> Promise<Void> {
        let error = FollowUpError.MissingParameter("invalid params")
        
        Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating subscriber, invalid params."])
        return Promise(error: error)
    }
    
    private func createFollowUpResource(params: [String: String]) -> FollowUpResource {
        return FollowUpResource(email: params["email"]!,
                                name: params["name"]!,
                                destination: params["destination_id"]!,
                                language: GTSettings.shared.primaryLanguageId!)
    }
    
    private func saveLocalCopy(_ localFollowUp: FollowUp) {
        safelyWriteToRealm {
            realm.add(localFollowUp)
        }
    }
    
    private func removeLocalCopy(_ localFollowUp: FollowUp) {
        safelyWriteToRealm {
            realm.delete(localFollowUp)
        }
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
    }

}
