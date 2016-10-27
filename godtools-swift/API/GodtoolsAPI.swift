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
    
    var genericAuthorizationToken: String?
    
    func getAccessToken () -> Promise<Any> {
        return Promise<Any>.init(resolvers: { (fulfill, reject) in
            Alamofire.request(baseURL + "/v2/auth", method: .post).response { response in
                let responseHeaders = response.response?.allHeaderFields as! NSDictionary
                self.genericAuthorizationToken = responseHeaders.value(forKey: "Authorization") as! String?
                
                fulfill(self.genericAuthorizationToken)
            }
        })
    }
    
    func getMeta() -> Promise<Any> {
        if (genericAuthorizationToken != nil) {
            return Alamofire.request(baseURL + "/v2/meta", headers: self.jsonHeaders()).responseJSON()
        }
        
        return getAccessToken().then(execute: {data in
            return Alamofire.request(self.baseURL + "/v2/meta", headers: self.jsonHeaders()).responseJSON()
        })
    }
    
    func getPackages(forLanguage: String) -> Promise<URL?> {
        let url = URL.init(string: self.baseURL + "/v2/packages/\(forLanguage)")!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("\(forLanguage).zip")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return Promise<URL?>.init(resolvers: { (fulfill, reject) in
            if (genericAuthorizationToken != nil) {
                Alamofire.download(url.absoluteString, to: destination).responseData { response in
                    fulfill(response.destinationURL)
                }
            }
            
            getAccessToken().then(execute: {data in
                Alamofire.download(url.absoluteString, to: destination).responseData { response in
                    fulfill(response.destinationURL)
                }
            }).catch(execute: { (error) in
                reject(error)
            })
        })
    }
    
    func defaultHeaders () -> Dictionary<String, String> {
        return [ "Authorization" : self.genericAuthorizationToken!,
        ]
    }
    
    func jsonHeaders () -> Dictionary<String, String> {
        return [ "Authorization" : self.genericAuthorizationToken!,
                 "Accept" : "application/json"
        ]
    }
    
}
