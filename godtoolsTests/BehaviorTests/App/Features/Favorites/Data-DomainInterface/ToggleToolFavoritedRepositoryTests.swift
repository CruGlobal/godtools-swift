//
//  ToggleToolFavoritedRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/28/25.
//  Copyright © 2025 Cru. All rights reserved.ogg
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync

struct ToggleToolFavoritedRepositoryTests {
    
    struct TestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdToToggle: String
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
       """
       Given: A user has any amount of tools favorited
       When: A user toggles the favorite icon on a single tool
       Then: If the tool is favorited, the tool should be removed from the favorites list.  If not favorited, the tool should be added to favorites at position 0.  Any existing favorite tool positions should update accordingly.
       """,
       arguments: [
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1], resourceIdToToggle: "C", expectedUpdatedIdsAtPositions: ["C": 0, "A": 1, "B": 2]),
        TestArgument(resourcesInRealmIdsAtPositions: [:], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: ["A": 0]),
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1]),
        TestArgument(resourcesInRealmIdsAtPositions: ["A": 0], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: [:])
       ]
    )
    @MainActor func testToggleToolFavorited(argument: TestArgument) async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let testsDiContainer = try TestsDiContainer(addRealmObjects: getRealmObjects(with: argument.resourcesInRealmIdsAtPositions))
        let realmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        let toggleToolFavoritedRepository = ToggleToolFavoritedRepository(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
        
        var favoritedResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            toggleToolFavoritedRepository.toggleFavoritedPublisher(toolId: argument.resourceIdToToggle)
                .sink { _ in
                    
                    favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                        FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
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
    
    
}

extension ToggleToolFavoritedRepositoryTests {
    
    private func getRealmObjects(with resources: [String: Int]) -> [IdentifiableRealmObject] {
        
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            let resource = RealmFavoritedResource(createdAt: Date(), resourceId: resourceId, position: resourcePosition)
            resourceObjects.append(resource)
        }
        
        return resourceObjects
    }
}
