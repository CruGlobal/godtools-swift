//
//  RemoveFavoritedToolRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine

struct RemoveFavoritedToolRepositoryTests {
    
    @Test(
        """
        Given: User is viewing all their favorite tools.
        When: a user unfavorites tool B
        Then: Tools C, D, and E should update to positions 1, 2, and 3. Tool A should remain unchanged.
        """
    )
    @MainActor func testRemoveFavoritedTool() async {
        
        var cancellables: Set<AnyCancellable> = Set()
                    
        let realmDatabase = getConfiguredRealmDatabase()
        let removeFavoritedToolRepository = RemoveFavoritedToolRepository(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
        
        var remainingResources: [FavoritedResourceDataModel] = Array()
                    
        await confirmation(expectedCount: 1) { confirmation in
            removeFavoritedToolRepository.removeToolPublisher(toolId: "B")
                .sink(receiveValue: { _ in
                    
                    remainingResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                        FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                    }
                    
                    confirmation()
                })
                .store(in: &cancellables)
        }
        
        #expect(remainingResources.first(where: { $0.id == "A" })?.position == 0)
        #expect(remainingResources.first(where: { $0.id == "B" }) == nil)
        #expect(remainingResources.first(where: { $0.id == "C" })?.position == 1)
        #expect(remainingResources.first(where: { $0.id == "D" })?.position == 2)
        #expect(remainingResources.first(where: { $0.id == "E" })?.position == 3)
    }
    
    private func getConfiguredRealmDatabase() -> RealmDatabase {
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

