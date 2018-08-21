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
import SwiftyJSON

enum FollowUpError: Error {
    case MissingParameter(String)
}

class FollowUpsManager: GTDataManager {
    
    let path = "follow_ups"
    
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
        guard let email = params["email"], email.count >= 0 else {
            return false
        }
        
        guard let name = params["name"], name.count >= 0 else {
            return false
        }
        
        guard let destinationId = params["destination_id"], destinationId.count >= 0 else {
            return false
        }
        
        guard let language = params["language_id"], language.count >= 0 else {
            return false
        }
        
        return true
    }
    
    private func postFollowUp(resource: FollowUpResource, cachedFollowUp: FollowUp) -> Promise<Void> {
        let jsonDictionary = ["data":
            ["type": "follow_up",
             "attributes": [
                "name": resource.name ?? "",
                "email": resource.email ?? "",
                "language_id": Int(resource.language_id ?? "-1") ?? -1,
                "destination_id": Int(resource.destination_id ?? "-1") ?? -1]]]
        
        return issuePOSTRequest(jsonDictionary)
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
