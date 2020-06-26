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
    let realm: Realm
    
    override init() {
        
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = documentsPath.appending("/").appending("Resources")
        bannersPath = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("Banners")
        realm = LegacyRealmDatabase.sharedMainThreadRealm
        
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
    
    func findEntity<T: Object>(_ entityClass: T.Type, matching: NSPredicate) -> T? {
        return findEntities(entityClass, matching: matching).first
    }
    
    func findEntity<T: Object>(_ entityClass: T.Type, byAttribute attribute: String, withValue value: Any) -> T? {
        let predicate = NSPredicate(format: attribute.appending(" = [c] %@"), value as! CVarArg)
        return findEntity(entityClass, matching: predicate)
    }
    
    func findEntityByRemoteId<T: Object>(_ entityClass: T.Type, remoteId: String) -> T? {
        return findEntity(entityClass, byAttribute: "remoteId", withValue: remoteId)
    }
    
    func findEntities<T: Object>(_ entityClass: T.Type, matching: NSPredicate, sortedByKeyPath: String? = nil) -> List<T> {
        let objects = realm.objects(entityClass)
        var filteredObjects = objects.filter(matching)
        if let sortedBy = sortedByKeyPath {
            filteredObjects = filteredObjects.sorted(byKeyPath: sortedBy)
        }
        return asList(filteredObjects)
    }
    
    func findAllEntities<T: Object>(_ entityClass: T.Type) -> List<T> {
        return asList(realm.objects(entityClass))
    }
    
    func findAllEntities<T: Object>(_ entityClass: T.Type, sortedByKeyPath: String) -> List<T> {
        return asList(realm.objects(entityClass).sorted(byKeyPath: sortedByKeyPath))
    }

    func safelyWriteToRealm(_ writeBlock: () -> Void ) {
        do {
            if realm.isInWriteTransaction {
                writeBlock()
            } else {
                try realm.write {
                    writeBlock()
                }
            }
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error saving to realm!"])
        }
    }
    
    func asList<T: Object>(_ results: Results<T>) -> List<T> {
        return results.reduce(List<T>()) { (list, element) -> List<T> in
            list.append(element)
            return list
        }
    }
    
    func buildURL() -> URL? {
        assertionFailure("method must be overridden")
        return nil
    }
}
