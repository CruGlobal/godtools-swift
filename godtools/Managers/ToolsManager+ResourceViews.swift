//
//  ToolsManager+ResourceViews.swift
//  godtools
//
//  Created by Ryan Carlson on 6/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON
import Crashlytics

extension ToolsManager {
    
    func recordViewed(_ resource: DownloadedResource) {
        recordViewOnRemote(resource, quantity: 1).catch { (error) in
            self.safelyWriteToRealm {
                resource.myViews += 1
            }
            self.record(error, resource: resource)
        }
    }
    
    func syncCachedRecordViews() {
        for resource in findAllEntities(DownloadedResource.self) {
    
            if resource.myViews == 0 {
                continue
            }
            recordViewOnRemote(resource, quantity: NSNumber(value: resource.myViews))
            .done { _ in
                self.safelyWriteToRealm {
                    resource.myViews = 0
                }
            }
            .catch { error in
                self.record(error, resource: resource)
            }
        }
    }
    
    private func recordViewOnRemote(_ resource: DownloadedResource, quantity: NSNumber) -> Promise<String> {
       
        let baseUrl: String = AppConfig().mobileContentApiBaseUrl
        let path: String = "/views"
        let url = URL(string: baseUrl + path)
        
        return Alamofire.request(url!,
                          method: .post,
                          parameters: buildParameters(resource: resource, quantity: quantity),
                          encoding: URLEncoding.default,
                          headers: nil)
            .validate()
            .responseString().then { rv -> Promise<String> in
               return .value(rv.string)
            }
                
    }
    
    private func buildParameters(resource: DownloadedResource, quantity: NSNumber) -> [String: Any]? {
        guard let resourceIdAsInt = Int(resource.remoteId) else { return nil }
        let dict = ["data":
            ["type": "view",
             "attributes": [
                "resource_id": resourceIdAsInt,
                "quantity": quantity]
            ]
        ]
        
        return dict
    }
    
    private func record(_ error: Error, resource: DownloadedResource) {
        Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Unable to sync views to remote for resource \(resource.remoteId)"])
    }
}
