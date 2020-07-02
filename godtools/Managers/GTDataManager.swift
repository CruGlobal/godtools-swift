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
import RealmSwift
import Crashlytics

enum DataManagerError: Error {
    case StatusCodeError(Int)
}

class GTDataManager: NSObject {
    
    let documentsPath: String
    let resourcesPath: String
    let bannersPath: URL
    
    override init() {
        
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = documentsPath.appending("/").appending("Resources")
        bannersPath = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("Banners")
        
        super.init()
    }
    
    func issueGETRequest() -> Promise<Data> {

        return Alamofire
            .request(buildURL() ?? "")
            .responseData().then { rv -> Promise<Data> in
                .value(rv.data)
            }
    }
        
    func issuePOSTRequest(_ params: Parameters) -> Promise<Data> {
        
        return Alamofire
            .request(buildURL() ?? "",
                     method: HTTPMethod.post,
                     parameters: params)
            .validate({ (request, response, data) -> Request.ValidationResult in
                if response.statusCode / 100 != 2 {
                    return .failure(DataManagerError.StatusCodeError(response.statusCode))
                }
                
                return .success
            })
            .responseData().then { rv -> Promise<Data> in
                .value(rv.data)
            }
    }
    
    func issueGETRequest(_ params: Parameters) -> Promise<Data> {
        
        return Alamofire.request(buildURL() ?? "",
                                 method: HTTPMethod.get,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: nil)
            .responseData().then { rv -> Promise<Data> in
                .value(rv.data)
            }
    }
    
    func buildURL() -> URL? {
        assertionFailure("method must be overridden")
        return nil
    }
}
