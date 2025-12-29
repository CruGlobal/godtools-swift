//
//  ReorderFavoritedToolRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine

struct ReorderFavoritedToolRepositoryTests {

    struct TestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdToReorder: String
        let originalPosition: Int
        let newPosition: Int
        let expectedUpdatedIdsAtPositions: [String: Int]
    }

    @Test(
       """
       Given: User is viewing all their favorite tools.
       When: A user drags a tool up or down in the list
       Then: The tool's position should update, and surrounding tool positions should update accordingly.
       """,
       arguments: [
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "C", originalPosition: 2, newPosition: 0, expectedUpdatedIdsAtPositions: ["C": 0, "A": 1, "B": 2, "D": 3, "E": 4]),
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "A", originalPosition: 0, newPosition: 4, expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "D": 2, "E": 3, "A": 4]),
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "E", originalPosition: 4, newPosition: 2, expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "E": 2, "C": 3, "D": 4])
       ]
    )
    @MainActor func testReorderFavorites(argument: TestArgument) async {
        
        var cancellables: Set<AnyCancellable> = Set()
             
        let realmDatabase = getConfiguredRealmDatabase(with: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepo = FavoritedResourcesRepository(
            cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)
        )
        let reorderFavoriteToolsRepository = ReorderFavoritedToolRepository(favoritedResourcesRepository: favoritedResourcesRepo)
        
        var favoritedResources: [ReorderFavoritedToolDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            reorderFavoriteToolsRepository.reorderFavoritedToolPubilsher(toolId: argument.resourceIdToReorder, originalPosition: argument.originalPosition, newPosition: argument.newPosition)
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                    favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                        ReorderFavoritedToolDomainModel(dataModelId: $0.resourceId, position: $0.position)
                    }
                    
                    confirmation()
                }
                .store(in: &cancellables)
        }
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition = favoritedResources.first(where: { $0.id == expectedId })?.position
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition ?? -1)"
            )
        }
    }
    
    private func getConfiguredRealmDatabase(with resources: [String: Int]) -> LegacyRealmDatabase {
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            let resource = RealmFavoritedResource(createdAt: Date(), resourceId: resourceId, position: resourcePosition)
            resourceObjects.append(resource)
        }
        
        return TestsInMemoryRealmDatabase(addObjectsToDatabase: resourceObjects)
    }
}
