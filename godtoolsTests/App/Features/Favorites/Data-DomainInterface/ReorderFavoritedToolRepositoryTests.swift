//
//  ReorderFavoritedToolRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class ReorderFavoritedToolRepositoryTests: QuickSpec {

    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
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
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase(addObjectsToDatabase: [favoriteResourceA, favoriteResourceB, favoriteResourceC, favoriteResourceD, favoriteResourceE] )
        
        describe("User is viewing all their favorite tools.") {
            
            context("When the user drags tool C to the top") {
                
                let reorderFavoriteToolsRepository = ReorderFavoritedToolRepository(
                    favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
                
                it("The tool C position should update to 0, tools A and B should update to 1 and 2, but D and E shouldn't change positions.") {
                    
                    var favoritedResources: [FavoritedResourceDataModel] = Array()
                    
                    waitUntil { done in
                        
                        reorderFavoriteToolsRepository.reorderFavoritedToolPubilsher(toolId: favoriteResourceC.resourceId, originalPosition: favoriteResourceC.position, newPosition: 0)
                            .sink { _ in
                                
                            } receiveValue: { favorites in
                                
                                favoritedResources = favorites
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(favoritedResources.first(where: { $0.id == "C" })?.position).to(equal(0))
                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "B" })?.position).to(equal(2))
                    expect(favoritedResources.count).to(equal(3))
                    expect(favoritedResources.first(where: { $0.id == "D" })).to(beNil())
                    expect(favoritedResources.first(where: { $0.id == "E" })).to(beNil())
                }
            }
            
        }
    }

}
