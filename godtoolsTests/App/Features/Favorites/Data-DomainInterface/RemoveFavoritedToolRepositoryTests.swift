//
//  RemoveFavoritedToolRepositoryTests.swift
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

class RemoveFavoritedToolRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User is viewing all their favorite tools.") {
            
            context("When a user unfavorites tool B") {
                it("Tools C, D, and E should update to positions 1, 2, and 3. Tool A should remain unchanged.") {
                    
                    let removeFavoritedToolRepository = RemoveFavoritedToolRepository(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: getConfiguredRealmDatabase())))
                    
                    var favoritedResources: [FavoritedResourceDataModel] = Array()
                    
                    waitUntil{ done in
                            
                        removeFavoritedToolRepository.removeToolPublisher(toolId: "B")
                            .sink { _ in
                                
                                let realmDatabase = getConfiguredRealmDatabase()
                                favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self)
                                    .map { FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)}
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(0))
                    expect(favoritedResources.first(where: { $0.id == "B" })).to(beNil())
                    expect(favoritedResources.first(where: { $0.id == "C" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "D" })?.position).to(equal(2))
                    expect(favoritedResources.first(where: { $0.id == "E" })?.position).to(equal(3))
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
        
        let favoriteResourceC = RealmFavoritedResource()
        favoriteResourceC.resourceId = "C"
        favoriteResourceC.position = 2
        
        let favoriteResourceD = RealmFavoritedResource()
        favoriteResourceD.resourceId = "D"
        favoriteResourceD.position = 3
        
        let favoriteResourceE = RealmFavoritedResource()
        favoriteResourceE.resourceId = "E"
        favoriteResourceE.position = 4
        
        return TestsInMemoryRealmDatabase(addObjectsToDatabase: [favoriteResourceA, favoriteResourceB, favoriteResourceC, favoriteResourceD, favoriteResourceE] )
    }
}

