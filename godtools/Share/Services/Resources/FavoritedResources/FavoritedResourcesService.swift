//
//  FavoritedResourcesService.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedResourcesService {
    
    typealias ResourceId = String
    
    private let favoritedResourcesCache: RealmFavoritedResourcesCache
    private let favoritedResourcesMemoryCache: FavoritedResourcesMemoryCache = FavoritedResourcesMemoryCache()
    
    private var didLoadMemoryCache: Bool = false
    
    let resourceFavorited: SignalValue<ResourceId> = SignalValue()
    let resourceUnfavorited: SignalValue<ResourceId> = SignalValue()
    let resourceSorted: SignalValue<ResourceId> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
        self.favoritedResourcesCache = RealmFavoritedResourcesCache(realmDatabase: realmDatabase)
    }
    
    func getFavoritedResources(completeOnMain: @escaping ((_ favoritedResources: [FavoritedResourceModel]) -> Void)) {
                
        favoritedResourcesCache.getFavoritedResources { [weak self] (cachedFavoritedResources: [RealmFavoritedResource]) in
            
            var favoritedResources: [FavoritedResourceModel] = Array()
            var favoritedResourcesIds: [String] = Array()
            
            for cachedFavoritedResource in cachedFavoritedResources {
                favoritedResources.append(FavoritedResourceModel(model: cachedFavoritedResource))
                favoritedResourcesIds.append(cachedFavoritedResource.resourceId)
            }
            
            self?.favoritedResourcesMemoryCache.setFavoritedResourceIds(resourceIds: favoritedResourcesIds)
            
            DispatchQueue.main.async { [weak self] in
                self?.didLoadMemoryCache = true
                completeOnMain(favoritedResources)
            }
        }
    }
    
    func isFavorited(resourceId: String, complete: @escaping ((_ isFavorited: Bool) -> Void)) {
        
        if didLoadMemoryCache {
            complete(favoritedResourcesMemoryCache.isFavorited(resourceId: resourceId))
        }
        else {
            favoritedResourcesCache.isFavorited(resourceId: resourceId, complete: complete)
        }
    }
    
    func toggleFavorited(resourceId: String) {
        isFavorited(resourceId: resourceId) { [weak self] (isFavorited: Bool) in
            if isFavorited {
                self?.removeFromFavorites(resourceId: resourceId)
            }
            else {
                self?.addToFavorites(resourceId: resourceId)
            }
        }
    }
    
    func addToFavorites(resourceId: String) {
        
        favoritedResourcesMemoryCache.addToFavorites(resourceId: resourceId)
        
        favoritedResourcesCache.addToFavorites(resourceId: resourceId) { (error: Error?) in
            DispatchQueue.main.async { [weak self] in
                self?.resourceFavorited.accept(value: resourceId)
            }
        }
    }
    
    func removeFromFavorites(resourceId: String) {

        favoritedResourcesMemoryCache.removeFromFavorites(resourceId: resourceId)

        favoritedResourcesCache.removeFromFavorites(resourceId: resourceId) { (error: Error?) in
            DispatchQueue.main.async { [weak self] in
                self?.resourceUnfavorited.accept(value: resourceId)
            }
        }
    }
    
    func setSortOrder(resourceId: String, sortOrder: Int) {
        
        favoritedResourcesCache.setSortOrder(resourceId: resourceId, newSortOrder: sortOrder) { (error: Error?) in

            DispatchQueue.main.async { [weak self] in
                self?.resourceSorted.accept(value: resourceId)
            }
        }
    }
}
