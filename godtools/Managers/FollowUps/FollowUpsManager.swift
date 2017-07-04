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
        
        let resource = createFollowUpResource(params: params)
        let localFollowUp = FollowUp(jsonAPIFollowUp: resource)
        
        saveLocalCopy(localFollowUp)
        
        return postFollowUp(resource: resource, cachedFollowUp: localFollowUp)
    }
    
    func syncCachedFollowUps() -> [Promise<Void>] {
        let predicate = NSPredicate(format: "retryCount < 3")
        let cachedFollowUps = findEntities(FollowUp.self, matching: predicate)
        
        if cachedFollowUps.count == 0 {
            return [Promise(value: ())]
        }
        
        var promises = [Promise<Void>]()
        
        for followUp in cachedFollowUps {
            let resource = createFollowUpResource(cachedFollowUp: followUp)
            
            promises.append(self.postFollowUp(resource: resource, cachedFollowUp: followUp))
        }
        
        return promises
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
    
    private func postFollowUp(resource: FollowUpResource, cachedFollowUp: FollowUp) -> Promise<Void> {
        let paramsData = try! self.serializer.serializeResources([resource])
        let paramsJSON = try! JSONSerialization.jsonObject(with: paramsData, options: []) as! [String: Any]
        
        return issuePOSTRequest(paramsJSON)
            .then { data -> Promise<Void> in
                self.removeLocalCopy(cachedFollowUp)
                return Promise(value: ())
            }
            .catch(execute: { error in
                self.incrementRetryCount(cachedFollowUp)
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating subscriber."])
            })
            .always {
                self.hideNetworkIndicator()
        }
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
                                language: params["language_id"]!)
    }
    
    private func createFollowUpResource(cachedFollowUp: FollowUp) -> FollowUpResource {
        return FollowUpResource(email: cachedFollowUp.email!,
                                name: cachedFollowUp.name!,
                                destination: cachedFollowUp.destinationId!,
                                language: cachedFollowUp.languageId!)
    }
    
    private func saveLocalCopy(_ localFollowUp: FollowUp) {
        safelyWriteToRealm {
            localFollowUp.createdAtTime = NSDate()
            realm.add(localFollowUp)
        }
    }
    
    private func removeLocalCopy(_ localFollowUp: FollowUp) {
        safelyWriteToRealm {
            realm.delete(localFollowUp)
        }
    }
    
    private func incrementRetryCount(_ localFollowUp: FollowUp) {
        safelyWriteToRealm {
            localFollowUp.retryCount += 1
        }
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
    }

}
