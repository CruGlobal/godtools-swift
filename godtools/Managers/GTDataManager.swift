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
    let documentsPath: String
    let resourcesPath: String
    
    let serializer = Serializer()
    let context = NSManagedObjectContext.mr_default()
    
    override init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = "\(documentsPath)/Resources"
        
        super.init()
    }
    
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
    
    func rollbackContext() {
        context.rollback()
    }
    
    func saveToDisk() {
        saveToDisk(nil)
    }
    
    func saveToDisk(_ completion: ((Bool, Error?) -> Void)?) {
        context.mr_saveToPersistentStore(completion: completion)
    }
    
    func saveToDiskAndWait() {
        context.mr_saveToPersistentStoreAndWait()
    }
    
    func findEntity<T: NSManagedObject>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T? {
        return entityClass.mr_findFirst(byAttribute: attribute, withValue: value, in: context)
    }
    
    func findEntities<T: NSManagedObject>(_ entityClass: T.Type, matching: NSPredicate) -> [T] {
        return entityClass.mr_findAll(with: matching, in: context) as! [T]
    }
    
    func findAllEntities<T: NSManagedObject>(_ entityClass: T.Type) -> [T] {
        return entityClass.mr_findAll(in: context) as! [T]
    }
    
    func createEntity<T: NSManagedObject>(_ entityClass: T.Type) -> T? {
        return entityClass.mr_createEntity(in: context)
    }
    
    func deleteEntities<T: NSManagedObject>(_ entityClass: T.Type, matching: NSPredicate) {
        entityClass.mr_deleteAll(matching: matching, in: context)
    }
    
    func buildURLString() -> String {
        assertionFailure("method must be overridden")
        return ""
    }
    
    func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
