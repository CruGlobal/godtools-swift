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
    
    let persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>
    
    init(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>? {
        return persistence as? SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>
    }

    private func getRealmPersistence() -> RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>? {
        return persistence as? RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>
    }
}

// MARK: - Queries

extension FavoritedResourcesCache {
    
    @available(iOS 17.4, *)
    private func getSwiftQuerySortedByPosition(order: SortOrder) -> SwiftDatabaseQuery<SwiftFavoritedResource> {
        
        return SwiftDatabaseQuery<SwiftFavoritedResource>.sort(
            sortBy: [SortDescriptor(\SwiftFavoritedResource.position, order: order)]
        )
    }
    
    private func getRealmQuerySortedByPosition(ascending: Bool) -> RealmDatabaseQuery {
        
        return RealmDatabaseQuery.sort(
            byKeyPath: SortByKeyPath(keyPath: #keyPath(RealmFavoritedResource.position), ascending: ascending)
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
            
            let favorites: [FavoritedResourceDataModel] = try await swiftPersistence
                .newActorRead()
                .getDataModels(
                    query: getSwiftQuerySortedByPosition(order: .forward)
                )
            
            return favorites
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let favorites: [FavoritedResourceDataModel] = try await realmPersistence
                .newActorRead()
                .getDataModels(
                    query: getRealmQuerySortedByPosition(ascending: true)
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
        
        _ = try await persistence.writeObjects(
            externalObjects: allFavoritedResourcesSorted,
            writeOption: nil,
            getOption: nil
        )
        
        return try await getFavoritedResourcesSortedByPosition()
    }
    
    func deleteFavoritedResource(id: String) async throws -> [FavoritedResourceDataModel] {
        
        let favoritedResourceToDelete: FavoritedResourceDataModel? = try persistence.getDataModel(id: id)
        
        guard let favoritedResourceToDelete = favoritedResourceToDelete else {
            return try await getFavoritedResourcesSortedByPosition()
        }
        
        var favoritedResources: [FavoritedResourceDataModel] = try await getFavoritedResourcesSortedByPosition()
        
        if let index = favoritedResources.firstIndex(where: { $0.id == favoritedResourceToDelete.id }) {
            favoritedResources.remove(at: index)
        }
        
        var favoritedResourcesToUpdate: [FavoritedResourceDataModel] = Array()
        
        for index in 0 ..< favoritedResources.count {
            
            favoritedResourcesToUpdate.append(
                favoritedResources[index].copy(position: index)
            )
        }
        
        _ = try await persistence.deleteObjectsByIds(ids: [id], getOption: nil)
        
        _ = try await persistence.writeObjects(externalObjects: favoritedResourcesToUpdate, writeOption: nil, getOption: nil)
        
        return favoritedResourcesToUpdate
    }
}
