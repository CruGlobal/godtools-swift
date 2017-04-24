//
//  GTDataManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Spine

class GTDataManager: NSObject {
    
    let serializer = Serializer()
    let reachabilityManager = NetworkReachabilityManager(host: "\(GTConstants.kApiBase)/monitors/lb")
    
    override init() {
        reachabilityManager?.startListening()
    }
    
    func issueGETRequest() -> Promise<Data> {
        if reachabilityManager!.isReachable {
            return Alamofire
                .request(buildURLString())
                .responseData()
        }
        
        return Promise(error: NSError(domain: "godtools", code: 502, userInfo: ["message" : "Network is not reachable"]))
    }
    
    func issueGETRequest(_ params: Parameters) -> Promise<Data> {
        return Alamofire.request(buildURLString(),
                                 method: HTTPMethod.get,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: nil)
            .responseData()
    }
    
    func buildURLString() -> String {
        assertionFailure("method must be overridden")
        return ""
    }
    
    func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
