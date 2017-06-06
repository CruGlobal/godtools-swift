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
import RealmSwift

class GTDataManager: NSObject {
    let documentsPath: String
    let resourcesPath: String
    let bannersPath: URL
    
    let serializer = Serializer()
    let realm = try! Realm()
    
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
        assertionFailure("method must be re-implemented")
    }
    
    func saveToDisk() {
        assertionFailure("method must be re-implemented")
    }
    
    func saveToDisk(_ completion: ((Bool, Error?) -> Void)?) {
        assertionFailure("method must be re-implemented")
    }
    
    func saveToDiskAndWait() {
        assertionFailure("method must be re-implemented")
    }
    
    func findEntity<T: Object>(_ entityClass: T.Type, matching: NSPredicate) -> T? {
        return findEntities(entityClass, matching: matching).first
    }
    
    func findEntity<T: Object>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T? {
        let predicate = NSPredicate(format: attribute.appending(" = %@"), [value])
        return findEntity(entityClass, matching: predicate)
    }
    
    func findEntities<T: Object>(_ entityClass: T.Type, matching: NSPredicate) -> Results<T> {
        return findAllEntities(entityClass).filter(matching)
    }
    
    func findFirstOrCreateEntity<T: Object>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T {
        if let entity = findEntity(entityClass, byAttribute: attribute, withValue: value) {
            return entity
        }
        
        return entityClass.init()
    }
    
    func findAllEntities<T: Object>(_ entityClass: T.Type) -> Results<T> {
        return realm.objects(entityClass)
    }
    
    func createEntity<T: Object>(_ entityClass: T.Type) -> T? {
        return entityClass.init()
    }
    
    func deleteEntities<T: Object>(_ entityClass: T.Type, matching: NSPredicate) {
        realm.delete(findEntities(entityClass, matching: matching))
    }
    
    func deleteEntity<T: Object>(_ entity: T) {
        realm.delete(entity)
    }
    
    func buildURL() -> URL? {
        assertionFailure("method must be overridden")
        return nil
    }
    
    func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
