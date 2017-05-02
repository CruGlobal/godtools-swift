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
import CoreData

class GTDataManager: NSObject {
    
    let serializer = Serializer()
    
    func issueGETRequest() -> Promise<Data> {
        return Alamofire
            .request(buildURLString())
            .responseData()
    }
    
    func issueGETRequest(_ params: Parameters) -> Promise<Data> {
        return Alamofire.request(buildURLString(),
                                 method: HTTPMethod.get,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: nil)
            .responseData()
    }
    
    func saveToDisk() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
    }
    
    func buildURLString() -> String {
        assertionFailure("method must be overridden")
        return ""
    }
    
    func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
