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

@Suite(.serialized)
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
    func testToggleToolFavorited(argument: TestArgument) async throws {
        
        let realmDatabase = try getRealmDatabase(resources: argument.resourcesInRealmIdsAtPositions)
        
        let toggleToolFavoritedRepository = ToggleToolFavoritedRepository(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var favoritedResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                toggleToolFavoritedRepository
                    .toggleFavoritedPublisher(toolId: argument.resourceIdToToggle)
                    .sink { _ in
                        
                        favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                            FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                        }
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
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
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: ToggleToolFavoritedRepositoryTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getFavoritedResources(resources: [String: Int]) -> [RealmFavoritedResource] {
        
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            let resource = RealmFavoritedResource(createdAt: Date(), resourceId: resourceId, position: resourcePosition)
            resourceObjects.append(resource)
        }
        
        return resourceObjects
    }
    
    private func getRealmDatabase(resources: [String: Int]) throws -> LegacyRealmDatabase {
        
        let realmObjects: [IdentifiableRealmObject] = getFavoritedResources(resources: resources)
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: realmObjects)
        
        return testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
    }
}
