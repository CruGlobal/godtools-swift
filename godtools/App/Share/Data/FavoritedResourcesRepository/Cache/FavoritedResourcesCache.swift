//
//  FavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import SwiftData
import RealmSwift

final class FavoritedResourcesCache {
    
    private let persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>
    
    init(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>? {
        return persistence as? SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>? {
        return persistence as? RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>
    }
}

// MARK: - Queries

extension FavoritedResourcesCache {
    
    @available(iOS 17.4, *)
    private func getSwiftQuerySortedByPositionAscending() -> SwiftDatabaseQuery<SwiftFavoritedResource> {
        
        return SwiftDatabaseQuery<SwiftFavoritedResource>.sort(
            sortBy: [SortDescriptor(\SwiftFavoritedResource.position, order: .forward)]
        )
    }
    
    private func getRealmQuerySortedByPositionAscending() -> RealmDatabaseQuery {
        
        return RealmDatabaseQuery.sort(
            byKeyPath: SortByKeyPath(keyPath: #keyPath(RealmFavoritedResource.position), ascending: true)
        )
    }
}

extension FavoritedResourcesCache {
    
    private func createNewFavoritedResourcesOrderedByPosition(ids: [String]) -> [FavoritedResourceDataModel] {
        
        let currentDate: Date = Date()
        let calendar: Calendar = Calendar.current
        
        var newFavoritedResources: [FavoritedResourceDataModel] = Array()
        
        for index in 0 ..< ids.count {
            
            guard let createdAtDate = calendar.date(byAdding: .second, value: index, to: currentDate) else {
                continue
            }
            
            let favoritedResource = FavoritedResourceDataModel(
                id: ids[index],
                createdAt: createdAtDate,
                position: index
            )
            
            newFavoritedResources.append(favoritedResource)
        }
        
        return newFavoritedResources
    }
    
    func getFavoritedResourcesSortedByPosition() async throws -> [FavoritedResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let favorites: [FavoritedResourceDataModel] = try await swiftPersistence.getDataModelsAsync(
                getOption: .allObjects,
                query: getSwiftQuerySortedByPositionAscending()
            )
            
            return favorites
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let favorites: [FavoritedResourceDataModel] = try await realmPersistence.getDataModelsAsync(
                getOption: .allObjects,
                query: getRealmQuerySortedByPositionAscending()
            )
            
            return favorites
        }
        
        return Array()
    }
    
    func storeFavoritedResources(ids: [String]) async throws -> [FavoritedResourceDataModel] {
        
        let existingFavoritedResourcesSortedByPosition: [FavoritedResourceDataModel] = try await getFavoritedResourcesSortedByPosition()
            .filter { (favoritedResource: FavoritedResourceDataModel) in
                !ids.contains(favoritedResource.id)
            }
        
        let newFavoritedResources: [FavoritedResourceDataModel] = createNewFavoritedResourcesOrderedByPosition(ids: ids)
        
        let allFavoritedResources: [FavoritedResourceDataModel] = newFavoritedResources + existingFavoritedResourcesSortedByPosition
        
        var allFavoritedResourcesSorted: [FavoritedResourceDataModel] = Array()
        
        for index in 0 ..< allFavoritedResources.count {
            
            allFavoritedResourcesSorted.append(
                allFavoritedResources[index].copy(position: index)
            )
        }
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            _ = try await swiftPersistence.writeObjectsAsync(
                externalObjects: allFavoritedResourcesSorted,
                writeOption: nil,
                getOption: nil
            )
            
            return try await getFavoritedResourcesSortedByPosition()
        }
        else if let realmPersistence = getRealmPersistence() {
            
            _ = try await realmPersistence.writeObjectsAsync(
                externalObjects: allFavoritedResourcesSorted,
                writeOption: nil,
                getOption: nil
            )
            
            return try await getFavoritedResourcesSortedByPosition()
        }
        else {
            
            return Array()
        }
    }
    
    func deleteFavoritedResource(id: String) async throws -> [FavoritedResourceDataModel] {
     
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let context: ModelContext = swiftPersistence.database.openContext()
            
            let favoritedResourceToDelete: SwiftFavoritedResource? = try swiftPersistence.database.read.object(context: context, id: id)
            
            guard let favoritedResourceToDelete = favoritedResourceToDelete else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            var favoritedResources: [SwiftFavoritedResource] = try swiftPersistence.database.read.objects(
                context: context,
                query: getSwiftQuerySortedByPositionAscending()
            )
            
            if let index = favoritedResources.firstIndex(where: { $0.id == favoritedResourceToDelete.id }) {
                favoritedResources.remove(at: index)
            }
            
            for index in 0 ..< favoritedResources.count {
                favoritedResources[index].position = index
            }
            
            try swiftPersistence.database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(
                    deleteObjects: [favoritedResourceToDelete],
                    insertObjects: favoritedResources
                )
            )
            
            let dataModels: [FavoritedResourceDataModel] = favoritedResources.map {
                $0.toModel()
            }
            
            return dataModels
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm: Realm = try realmPersistence.database.openRealm()
            
            let favoritedResourceToDelete: RealmFavoritedResource? = realmPersistence.database.read.object(realm: realm, id: id)
            
            guard let favoritedResourceToDelete = favoritedResourceToDelete else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            var favoritedResources: [RealmFavoritedResource] = realmPersistence.database.read.objects(
                realm: realm,
                query: getRealmQuerySortedByPositionAscending()
            )
            
            if let index = favoritedResources.firstIndex(where: { $0.id == favoritedResourceToDelete.id }) {
                favoritedResources.remove(at: index)
            }
            
            let remainingFavoritedResources: [RealmFavoritedResource] = favoritedResources.map {
                RealmFavoritedResource.createNewFrom(model: $0.toModel())
            }
            
            for index in 0 ..< remainingFavoritedResources.count {
                remainingFavoritedResources[index].position = index
            }
            
            try realmPersistence.database.write.realm(
                realm: realm,
                writeClosure: { (realm: Realm) in
                    return WriteRealmObjects(
                        deleteObjects: [favoritedResourceToDelete],
                        addObjects: remainingFavoritedResources
                    )
                },
                updatePolicy: .modified
            )

            let dataModels: [FavoritedResourceDataModel] = remainingFavoritedResources.map {
                $0.toModel()
            }
            
            return dataModels
        }
        
        return Array()
    }
    
    func reorderFavoritedResource(id: String, originalPosition: Int, newPosition: Int) async throws -> [FavoritedResourceDataModel] {
     
        let resourceToUpdate: FavoritedResourceDataModel? = try persistence.getDataModel(id: id)
        
        guard let resourceToUpdate = resourceToUpdate, resourceToUpdate.position == originalPosition && resourceToUpdate.position != newPosition else {
            return try await getFavoritedResourcesSortedByPosition()
        }
        
        let placeholderId: String = "placeholder"
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let context: ModelContext = swiftPersistence.database.openContext()
            
            var favoritedResources: [SwiftFavoritedResource] = try swiftPersistence.database.read.objects(
                context: context,
                query: getSwiftQuerySortedByPositionAscending()
            )
            
            let placeholderResource = SwiftFavoritedResource()
            placeholderResource.id = placeholderId
            
            favoritedResources.insert(placeholderResource, at: originalPosition)
            
            guard let index = favoritedResources.firstIndex(where: { $0.id == id }) else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            let resourceToMove: SwiftFavoritedResource = favoritedResources.remove(at: index)
            
            if newPosition > originalPosition {
                favoritedResources.insert(resourceToMove, at: newPosition + 1)
            }
            else {
                favoritedResources.insert(resourceToMove, at: newPosition)
            }
                        
            guard let placeholderIndex = favoritedResources.firstIndex(where: { $0.id == placeholderId }) else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            favoritedResources.remove(at: placeholderIndex)
            
            for index in 0 ..< favoritedResources.count {
                favoritedResources[index].position = index
            }
            
            try swiftPersistence.database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(
                    deleteObjects: nil,
                    insertObjects: favoritedResources
                )
            )
            
            let dataModels: [FavoritedResourceDataModel] = favoritedResources.map {
                $0.toModel()
            }
            
            return dataModels
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm: Realm = try realmPersistence.database.openRealm()
            
            var favoritedResources: [RealmFavoritedResource] = realmPersistence.database.read.objects(
                realm: realm,
                query: getRealmQuerySortedByPositionAscending()
            ).map {
                RealmFavoritedResource.createNewFrom(realmResource: $0)
            }
            
            let placeholderResource = RealmFavoritedResource()
            placeholderResource.id = placeholderId
            
            favoritedResources.insert(placeholderResource, at: originalPosition)
            
            guard let index = favoritedResources.firstIndex(where: { $0.id == id }) else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            let resourceToMove: RealmFavoritedResource = favoritedResources.remove(at: index)
            
            if newPosition > originalPosition {
                favoritedResources.insert(resourceToMove, at: newPosition + 1)
            }
            else {
                favoritedResources.insert(resourceToMove, at: newPosition)
            }

            guard let placeholderIndex = favoritedResources.firstIndex(where: { $0.id == placeholderId }) else {
                return try await getFavoritedResourcesSortedByPosition()
            }
            
            favoritedResources.remove(at: placeholderIndex)
            
            for index in 0 ..< favoritedResources.count {
                favoritedResources[index].position = index
            }
            
            try realmPersistence.database.write.realm(
                realm: realm,
                writeClosure: { (realm: Realm) in
                    return WriteRealmObjects(
                        deleteObjects: nil,
                        addObjects: favoritedResources
                    )
                },
                updatePolicy: .modified
            )
            
            let dataModels: [FavoritedResourceDataModel] = favoritedResources.map {
                $0.toModel()
            }
            
            return dataModels
        }
        
        return Array()
    }
}
