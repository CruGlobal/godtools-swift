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

extension ToolsManager {
    
    func recordViewed(_ resource: DownloadedResource) {
        recordViewOnRemote(resource).catch { (error) in
            resource.myViews += 1
            self.saveToDisk()
        }
    }
    
    private func recordViewOnRemote(_ resource: DownloadedResource) -> Promise<String> {
        return Alamofire.request((Config.shared().baseUrl?.appendingPathComponent(viewsPath))!,
                          method: .post,
                          parameters: buildParameters(resource: resource),
                          encoding: URLEncoding.default,
                          headers: nil)
            .validate()
            .responseString()
        
    }
    
    private func buildParameters(resource: DownloadedResource) -> [String: Any] {
        let resourceViews = ResourceViews(resourceId: NSNumber(value: Int(resource.remoteId!)!),
                                          quantity: 1)
        
        
        let paramsData = try! self.serializer.serializeResources([resourceViews])
        return try! JSONSerialization.jsonObject(with: paramsData, options: []) as! [String: Any]
    }
}
