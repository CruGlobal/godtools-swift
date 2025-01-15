//
//  RemoteConfigCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RemoteConfigCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getRemoteConfigChangedPublisher(id: String) -> AnyPublisher<RemoteConfigDataModel?, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmRemoteConfigObject.self)
            .objectWillChange
            .map { _ in
                
                return self.getRemoteConfig(id: id)
            }
            .eraseToAnyPublisher()
    }
    
    private func getRemoteConfig(id: String) -> RemoteConfigDataModel? {
        
        let realmObject: RealmRemoteConfigObject? = realmDatabase.readObject(primaryKey: id)
        
        let dataModel: RemoteConfigDataModel?
        
        if let realmObject = realmObject {
            
            dataModel = RemoteConfigDataModel(realmObject: realmObject)
        }
        else {
            
            dataModel = nil
        }
        
        return dataModel
    }
    
    func storeRemoteConfigPublisher(remoteConfigDataModel: RemoteConfigDataModel) -> AnyPublisher<RemoteConfigDataModel, Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let realmRemoteConfigObject = RealmRemoteConfigObject()
            
            realmRemoteConfigObject.mapFrom(dataModel: remoteConfigDataModel)
            
            return [realmRemoteConfigObject]
            
        } mapInBackgroundClosure: { (objects: [RealmRemoteConfigObject]) in
            
            let dataModels: [RemoteConfigDataModel] = objects.map {
                RemoteConfigDataModel(realmObject: $0)
            }
            
            return dataModels
        }
        .map { (dataModels: [RemoteConfigDataModel]) in
            
            return remoteConfigDataModel
        }
        .eraseToAnyPublisher()
    }
}
