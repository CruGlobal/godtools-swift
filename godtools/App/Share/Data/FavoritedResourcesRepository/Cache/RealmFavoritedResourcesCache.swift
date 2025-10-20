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
    
    func getFavoritedResourcesSortedByPositionPublisher() -> AnyPublisher<[FavoritedResourceDataModel], Never> {
        
        return getFavoritedResourcesChangedPublisher()
            .flatMap { _ in

                return self.getFavoritesSortedByPositionPublisher()
                    .map { (favoritedResources: [RealmFavoritedResource]) in
                        return favoritedResources.map{ FavoritedResourceDataModel(realmFavoritedResource: $0) }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
        
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<Void, Never> {
        
        let currentDate: Date = Date()
        let calendar: Calendar = Calendar.current
        
        var newFavoritedResources: [FavoritedResourceDataModel] = Array()
        
        for index in 0 ..< ids.count {
            
            guard let createdAtDate = calendar.date(byAdding: .second, value: index, to: currentDate) else {
                continue
            }
            
            let favoritedResource = FavoritedResourceDataModel(id: ids[index], createdAt: createdAtDate, position: index)
            
            newFavoritedResources.append(favoritedResource)
        }

        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmFavoritedResource] in
            
            let existingFavorites = realm.objects(RealmFavoritedResource.self)
            for favorite in existingFavorites {
                favorite.position += newFavoritedResources.count
            }
            
            let realmNewResources: [RealmFavoritedResource] = newFavoritedResources.map {
                
                let realmFavoritedResource = RealmFavoritedResource()
                realmFavoritedResource.resourceId = $0.id
                realmFavoritedResource.createdAt = $0.createdAt
                realmFavoritedResource.position = $0.position
                
                return realmFavoritedResource
            }
            
            return realmNewResources + Array(existingFavorites)
            
        } mapInBackgroundClosure: { (objects: [RealmFavoritedResource]) -> [Any] in
            return []
        }
        .catch({ error in
            print(error)
            return Just([])
        })
        .map { _ in
            return ()
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
            
            guard realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: id)?.position == originalPosition else { return [] }
            
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
    
    // MARK: - Private
    
    private func getFavoritesSortedByPositionPublisher() -> AnyPublisher<[RealmFavoritedResource], Never> {
        
        let realm = realmDatabase.openRealm()
        
        let favoritesSortedByPosition = Array(
            realm.objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.position), ascending: true)
        )
        
        if favoritesSortedByPosition.allSatisfy({ $0.position == 0 }) {
            
            return migrateExistingFavoritesToPositionsPublisher()
                .replaceError(with: [])
                .eraseToAnyPublisher()
            
        } else {
            return Just(favoritesSortedByPosition)
                .eraseToAnyPublisher()
        }
    }
    
    @available(*, deprecated)
    private func migrateExistingFavoritesToPositionsPublisher() -> AnyPublisher<[RealmFavoritedResource], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let favoritesSortedByCreatedAt = realm
                .objects(RealmFavoritedResource.self)
                .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: false)
                        
            var correctedPosition = 0
            for favorite in favoritesSortedByCreatedAt {
                favorite.position = correctedPosition
                correctedPosition += 1
            }
            
            return Array<RealmFavoritedResource>()
            
        } mapInBackgroundClosure: { (realmFavoritedResources: [RealmFavoritedResource]) in
           
            return realmFavoritedResources
        }
        .eraseToAnyPublisher()
    }
}
