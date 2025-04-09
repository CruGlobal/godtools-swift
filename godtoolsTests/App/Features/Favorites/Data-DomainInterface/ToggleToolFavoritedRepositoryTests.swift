//
//  ToggleToolFavoritedRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class ToggleToolFavoritedRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User has only tools A and B favorited.") {
            
            context("When a user favorites tool C") {
                it("Tool C should get added to favorites at position 0.  Positions of tools A and B should update to 1 and 2 respectively") {
                    
                    let realmDatabase = getConfiguredRealmDatabase()
                    let toggleToolFavoritedRepository = ToggleToolFavoritedRepository(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
                    
                    var favoritedResources: [FavoritedResourceDataModel] = Array()
                    
                    waitUntil{ done in
                        toggleToolFavoritedRepository.toggleFavoritedPublisher(toolId: "C")
                            .sink { _ in
                                
                                favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                                    FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                                }
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(favoritedResources.first(where: { $0.id == "C" })?.position).to(equal(0))
                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "B" })?.position).to(equal(2))
                }
            }
            
        }
    }
    
    private class func getConfiguredRealmDatabase() -> RealmDatabase {
        let favoriteResourceA = RealmFavoritedResource()
        favoriteResourceA.resourceId = "A"
        favoriteResourceA.position = 0
        
        let favoriteResourceB = RealmFavoritedResource()
        favoriteResourceB.resourceId = "B"
        favoriteResourceB.position = 1
        
        return Self.getConfiguredRealmDatabase(includeFavoritedTools: [favoriteResourceA, favoriteResourceB])
    }
    
    private class func getConfiguredRealmDatabase(includeFavoritedTools: [RealmFavoritedResource]) -> RealmDatabase {
    
        return TestsInMemoryRealmDatabase(addObjectsToDatabase: includeFavoritedTools)
    }
}

