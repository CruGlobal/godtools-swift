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
                .then(execute: { (_) -> Promise<Void> in
                    self.safelyWriteToRealm {
                        resource.myViews = 0
                    }
                    return Promise(value: ())
                })
                .catch(execute: { (error) in
                    self.record(error, resource: resource)
                })
        }
    }
    
    private func recordViewOnRemote(_ resource: DownloadedResource, quantity: NSNumber) -> Promise<String> {
        return Alamofire.request((Config.shared().baseUrl?.appendingPathComponent(viewsPath))!,
                          method: .post,
                          parameters: buildParameters(resource: resource, quantity: quantity),
                          encoding: URLEncoding.default,
                          headers: nil)
            .validate()
            .responseString()
    }
    
    private func buildParameters(resource: DownloadedResource, quantity: NSNumber) -> [String: Any]? {
        let resourceViews = ResourceViews(resourceId: NSNumber(value: Int(resource.remoteId)!),
                                          quantity: quantity)

        let json = JSON(resourceViews);
        return json.dictionaryObject
    }
    
    private func record(_ error: Error, resource: DownloadedResource) {
        Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Unable to sync views to remote for resource \(resource.remoteId)"])
    }
}
