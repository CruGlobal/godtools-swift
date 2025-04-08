//
//  FavoritedResourcesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 4/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class FavoritedResourcesRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User has only tools A and B favorited.") {
            
            context("Tool C, D, and E are all added to favorites simultaneously") {
                it("Tool C, D, and E should get added to favorites at position 0, 1, and 2.  Positions of tools A and B should update to 3 and 4 respectively") {
                    
                    let realmDatabase = getConfiguredRealmDatabase()
                    let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
                    
                    var favoritedResources: [FavoritedResourceDataModel] = Array()
                    
                    waitUntil{ done in
                        favoritedResourcesRepository.storeFavoritedResourcesPublisher(ids: ["C", "D", "E"])
                            .sink(receiveCompletion: { _ in
                                
                            }, receiveValue: { resources in
                                
                                favoritedResources = resources
                                
                                done()
                            })
                            .store(in: &cancellables)
                    }
                    
                    expect(favoritedResources.first(where: { $0.id == "C" })?.position).to(equal(0))
                    expect(favoritedResources.first(where: { $0.id == "D" })?.position).to(equal(1))
                    expect(favoritedResources.first(where: { $0.id == "E" })?.position).to(equal(2))
                    expect(favoritedResources.first(where: { $0.id == "A" })?.position).to(equal(3))
                    expect(favoritedResources.first(where: { $0.id == "B" })?.position).to(equal(4))
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
        
        return TestsInMemoryRealmDatabase(addObjectsToDatabase: [favoriteResourceA, favoriteResourceB] )
    }
}


