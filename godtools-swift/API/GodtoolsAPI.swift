//
//  GodtoolsAPI.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Alamofire

class GodtoolsAPI: NSObject {
    
    static let sharedInstance = GodtoolsAPI()
    
    var genericAuthorizationToken :String = ""
    
    func getAccessToken () {
        Alamofire.request("https://api.godtoolsapp.com/godtools-api/rest/v2/auth", method: .post).responseJSON { response in
            for(header, value) in (response.response?.allHeaderFields)! {
                if (header.description == "Authorization") {
                    self.genericAuthorizationToken = "\(value)"
                }
            }
        }
    }
    
    func getMeta() {
        let headers = [ "Authorization" : self.genericAuthorizationToken,
            "Accept" : "application/json"
        ]
        
        Alamofire.request("https://api.godtoolsapp.com/godtools-api/rest/v2/meta", headers: headers).responseJSON { response in
            debugPrint(response.result.value)
        }
    }
}
