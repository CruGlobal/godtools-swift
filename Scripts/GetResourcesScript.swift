//
//  GetResourcesScript.swift
//  godtools
//
//  Created by Levi Eggert on 8/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

@main
enum GetResourcesScript {
 
    private static var resourcesRequest: URLSessionDataTask?
    
    static func main() {
        
        print("Hello Xcode")
      
        if let value = ProcessInfo.processInfo.environment["PRODUCT_NAME"] {
            print("Product Name is: \(value)")
        }
        
        if let value = ProcessInfo.processInfo.environment["CONFIGURATION"] {
            print("Configuration is: \(value)")
        }
        
        let session: URLSession = GetResourcesScript.getSession()
        let resourcesRequest: URLRequest = URLRequest(url: URL(string: "https://mobile-content-api.cru.org/resources?include=latest-translations,attachments")!)
        
        print("start resources request...")
        
        GetResourcesScript.resourcesRequest = session.dataTask(with: resourcesRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            print("resources request finished")
            
            if let data = data {
                print("data: \(String(decoding: data, as: UTF8.self))")
            }
        }
    }
    
    private static func getSession() -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
     
        return URLSession(configuration: configuration)
    }
}
