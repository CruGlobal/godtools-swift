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
import Spine
import Crashlytics

extension ToolsManager {
    
    func recordViewed(_ resource: DownloadedResource) {
        recordViewOnRemote(resource, quantity: 1).catch { (error) in
            resource.myViews += 1
            self.saveToDisk()
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
                    resource.myViews = 0
                    self.saveToDisk()
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
    
    private func buildParameters(resource: DownloadedResource, quantity: NSNumber) -> [String: Any] {
        let resourceViews = ResourceViews(resourceId: NSNumber(value: Int(resource.remoteId)!),
                                          quantity: quantity)
        
        
        let paramsData = try! self.serializer.serializeResources([resourceViews])
        return try! JSONSerialization.jsonObject(with: paramsData, options: []) as! [String: Any]
    }
    
    private func record(_ error: Error, resource: DownloadedResource) {
        Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Unable to sync views to remote for resource \(resource.remoteId)"])
    }
}
