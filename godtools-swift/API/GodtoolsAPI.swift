//
//  GodtoolsAPI.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class GodtoolsAPI: NSObject {
    
    static let sharedInstance = GodtoolsAPI()
    let baseURL = "https://api.godtoolsapp.com/godtools-api/rest"
    
    var genericAuthorizationToken :String = ""
    
    func getAccessToken () -> Promise<Any> {
        return Alamofire.request(baseURL + "/v2/auth", method: .post).responseJSON()
    }
    
    func getMeta() -> Promise<Any> {
        return Alamofire.request(baseURL + "/v2/meta", headers: self.defaultHeaders()).responseJSON()
    }
    
    func defaultHeaders () -> Dictionary<String, String> {
        return [ "Authorization" : self.genericAuthorizationToken,
                 "Accept" : "application/json"
        ]
    }
}
