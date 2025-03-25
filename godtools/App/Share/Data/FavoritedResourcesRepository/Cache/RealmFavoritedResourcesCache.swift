//
//  RealmFavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmFavoritedResourcesCache {
        
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getNumberOfFavoritedResources() -> Int {
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self).count
    }
    
    func getFavoritedResourcesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmFavoritedResource.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResourcePublisher(id: String) -> AnyPublisher<FavoritedResourceDataModel?, Never> {
        
        let favoritedResource: FavoritedResourceDataModel? = getFavoritedResource(resourceId: id)
        
        return Just(favoritedResource)
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResource(resourceId: String) -> FavoritedResourceDataModel? {
        
        guard let realmFavoritedResource = realmDatabase.openRealm()
            .object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            
            return nil
        }
        
        return FavoritedResourceDataModel(realmFavoritedResource: realmFavoritedResource)
    }
    
    func getResourceIsFavorited(id: String) -> Bool {
            
        return realmDatabase.openRealm()
            .object(ofType: RealmFavoritedResource.self, forPrimaryKey: id) != nil
    }
    
    func getFavoritedResourcesSortedByCreatedAt(ascendingOrder: Bool) -> [FavoritedResourceDataModel] {
        
        return realmDatabase.openRealm()
            .objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: ascendingOrder)
            .map({FavoritedResourceDataModel(realmFavoritedResource: $0)})
    }
    
    func getFavoritedResourcesSortedByPosition(ascendingOrder: Bool = true) -> [FavoritedResourceDataModel] {
        
        return realmDatabase.openRealm()
            .objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.position), ascending: ascendingOrder)
            .map({FavoritedResourceDataModel(realmFavoritedResource: $0)})
    }
    
    func getFavoritedResourcesSortedByCreatedAtPublisher(ascendingOrder: Bool) -> AnyPublisher<[FavoritedResourceDataModel], Never> {
        
        let favoritedResources: [FavoritedResourceDataModel] = realmDatabase.openRealm()
            .objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: ascendingOrder)
            .map({
                return FavoritedResourceDataModel(realmFavoritedResource: $0)
            })
        
        return Just(favoritedResources)
            .eraseToAnyPublisher()
    }
        
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        let currentDate: Date = Date()
        let calendar: Calendar = Calendar.current
        
        var newFavoritedResources: [FavoritedResourceDataModel] = Array()
        
        for index in 0 ..< ids.count {
            
            guard let createdAtDate = calendar.date(byAdding: .second, value: index, to: currentDate) else {
                continue
            }
            
            let favoritedResource = FavoritedResourceDataModel(id: ids[index], createdAt: createdAtDate, position: 0)
            
            newFavoritedResources.append(favoritedResource)
        }

        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmFavoritedResource] in
            
            let existingFavorites = realm.objects(RealmFavoritedResource.self)
            for favorite in existingFavorites {
                favorite.position += newFavoritedResources.count
            }
            
            let realmFavoritedResources: [RealmFavoritedResource] = newFavoritedResources.map {
                
                let realmFavoritedResource = RealmFavoritedResource()
                realmFavoritedResource.resourceId = $0.id
                realmFavoritedResource.createdAt = $0.createdAt
                realmFavoritedResource.position = $0.position
                
                return realmFavoritedResource
            }
            
            return realmFavoritedResources + Array(existingFavorites)
            
        } mapInBackgroundClosure: { (objects: [RealmFavoritedResource]) -> [FavoritedResourceDataModel] in
            return objects.map({
                FavoritedResourceDataModel(realmFavoritedResource: $0)
            })
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        return realmDatabase.writeObjectsPublisher { realm in
            
            guard let positionToDelete = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: id)?.position else { return [] }
            
            let resourcesToMoveUp = realm.objects(RealmFavoritedResource.self).where({ $0.position >= positionToDelete })
            for resource in resourcesToMoveUp {
                resource.position -= 1
            }
            
            return Array(resourcesToMoveUp)
            
        } mapInBackgroundClosure: { objects in
            return []
        }
        .flatMap { _ in
            return self.realmDatabase.deleteObjectsInBackgroundPublisher(
                type: RealmFavoritedResource.self,
                primaryKeyPath: #keyPath(RealmFavoritedResource.resourceId),
                primaryKeys: [id]
            )
        }
        .eraseToAnyPublisher()
    }
    
    func reorderFavoritedResourcePublisher(id: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { realm in
            var resourcesToUpdate: [RealmFavoritedResource] = []
            
            if newPosition - originalPosition > 0 {
                let resourcesToMoveUp = realm.objects(RealmFavoritedResource.self).where({ $0.position >= originalPosition && $0.position <= newPosition })
                for resource in resourcesToMoveUp {
                    resource.position -= 1
                }
                
                resourcesToUpdate += resourcesToMoveUp
            } else {
                let resourcesToMoveDown = realm.objects(RealmFavoritedResource.self).where( { $0.position <= originalPosition && $0.position >= newPosition})
                for resource in resourcesToMoveDown {
                    resource.position += 1
                }
                
                resourcesToUpdate += resourcesToMoveDown
            }
            
            if let resourceToMove = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: id) {
                resourceToMove.position = newPosition
                resourcesToUpdate.append(resourceToMove)
            }
            
            return resourcesToUpdate
            
        } mapInBackgroundClosure: { (objects: [RealmFavoritedResource]) in
            return objects.map({
                FavoritedResourceDataModel(realmFavoritedResource: $0)
            })
        }
        .eraseToAnyPublisher()
    }
}
