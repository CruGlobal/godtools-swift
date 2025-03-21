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
            
            let reorderFavoriteToolsRepository = ReorderFavoritedToolRepository(
                favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
            
            context("When the user drags tool C to the top") {
                // C, A, B, D, E
                it("The tool C position should update to 0, tools A and B should update to 1 and 2, but D and E shouldn't change.") {
                    
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
                    
                    expect(favoritedResources.count).to(equal(3))
                    
                    expect(favoritedResources.first(where: { $0.id == "C" })?.position).to(equal(0))
                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "B" })?.position).to(equal(2))
                }
            }
            
            context("When the user drags tool A to the bottom") {
                // C, B, D, E, A
                it("The tool A position should update to 4, tool C remains unchanged, and B, D, E should update to 1, 2, 3.") {
                    
                    var favoritedResources: [FavoritedResourceDataModel] = Array()
                    
                    waitUntil { done in
                        
                        reorderFavoriteToolsRepository.reorderFavoritedToolPubilsher(toolId: favoriteResourceA.resourceId, originalPosition: favoriteResourceA.position, newPosition: 4)
                            .sink { _ in
                                
                            } receiveValue: { favorites in
                                
                                favoritedResources = favorites
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(favoritedResources.count).to(equal(5))

                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(4))
                    expect(favoritedResources.first(where: { $0.id == "B" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "D" })?.position).to(equal(2))
                    expect(favoritedResources.first(where: { $0.id == "E" })?.position).to(equal(3))
                }
            }
        }
    }

}
