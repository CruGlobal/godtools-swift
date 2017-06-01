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
    let bannersPath: URL
    
    let serializer = Serializer()
    let context = NSManagedObjectContext.mr_rootSaving()
    
    override init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = documentsPath.appending("/").appending("Resources")
        bannersPath = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("Banners")
        
        super.init()
    }
    
    func issueGETRequest() -> Promise<Data> {
        return Alamofire
            .request(buildURL() ?? "")
            .responseData()
    }
    
    func issueGETRequest(_ params: Parameters) -> Promise<Data> {
        return Alamofire.request(buildURL() ?? "",
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
    
    func findEntity<T: NSManagedObject>(_ entityClass: T.Type, matching: NSPredicate) -> T? {
        return entityClass.mr_findFirst(with: matching, in: context)
    }
    
    func findEntity<T: NSManagedObject>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T? {
        return entityClass.mr_findFirst(byAttribute: attribute, withValue: value, in: context)
    }
    
    func findEntities<T: NSManagedObject>(_ entityClass: T.Type, matching: NSPredicate) -> [T] {
        return entityClass.mr_findAll(with: matching, in: context) as! [T]
    }
    
    func findFirstOrCreateEntity<T: NSManagedObject>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T {
        return entityClass.mr_findFirstOrCreate(byAttribute: attribute, withValue: value, in: context)
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
    
    func deleteEntity<T: NSManagedObject>(_ entity: T) {
        entity.mr_deleteEntity(in: context)
    }
    
    func buildURL() -> URL? {
        assertionFailure("method must be overridden")
        return nil
    }
    
    func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
