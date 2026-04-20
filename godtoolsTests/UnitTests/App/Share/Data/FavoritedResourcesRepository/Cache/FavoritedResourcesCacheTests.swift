//
//  FavoritedResourcesCacheTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 4/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync

@Suite(.serialized)
struct FavoritedResourcesCacheTests {
    
    struct StoreTestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdsToAdd: [String]
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
        "Tools should be added to favorites and all resource positions updated in reserve order that they were added.",
        arguments: [
            StoreTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1], resourceIdsToAdd: ["C", "D", "E"], expectedUpdatedIdsAtPositions: ["C": 0, "D": 1, "E": 2, "A": 3, "B": 4]),
            StoreTestArgument(resourcesInRealmIdsAtPositions: [:], resourceIdsToAdd: ["A", "B", "C"], expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2])
        ]
    )
    func storeFavoritedResources(argument: StoreTestArgument) async throws {
        
        let favoritedResourcesCache: FavoritedResourcesCache = try getFavoritedResourcesCache(
            addResources: argument.resourcesInRealmIdsAtPositions
        )
        
        let favoritedResources: [FavoritedResourceDataModel] = try await favoritedResourcesCache
            .storeFavoritedResources(ids: argument.resourceIdsToAdd)
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition: Int = try #require(favoritedResources.first(where: { $0.id == expectedId })?.position)
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
    
    struct DeleteTestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdToDelete: String
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
        "Deleting a favorited tool should remove it from favorites and update positions of remaining resources.",
        arguments: [
            DeleteTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1]),
            DeleteTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A":0, "C":1]),
            DeleteTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "C", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1]),
            DeleteTestArgument(resourcesInRealmIdsAtPositions: ["A": 0], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: [:]),
            DeleteTestArgument(resourcesInRealmIdsAtPositions: ["A": 0], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A": 0])
        ]
    )
    func deleteFavoritedResource(argument: DeleteTestArgument) async throws {
                
        let favoritedResourcesCache: FavoritedResourcesCache = try getFavoritedResourcesCache(
            addResources: argument.resourcesInRealmIdsAtPositions
        )
        
        let remainingResources: [FavoritedResourceDataModel] = try await favoritedResourcesCache
            .deleteFavoritedResource(id: argument.resourceIdToDelete)

        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition: Int = try #require(remainingResources.first(where: { $0.id == expectedId })?.position)
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
    
    struct ReorderTestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdToReorder: String
        let originalPosition: Int
        let newPosition: Int
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
        "Reordering a favorited tool should move the tool to the new position, and update the surrounding tools' positions accordingly.",
        arguments: [
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdToReorder: "A", originalPosition: 0, newPosition: 2, expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "A": 2]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["H": 0, "I": 1, "J": 2, "K": 3], resourceIdToReorder: "K", originalPosition: 3, newPosition: 0, expectedUpdatedIdsAtPositions: ["K": 0, "H": 1, "I": 2, "J": 3]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["Q": 0, "R": 1, "S": 2, "T": 3], resourceIdToReorder: "R", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["Q": 0, "S": 1, "R": 2, "T": 3]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["U": 0, "V": 1, "W": 2, "X": 3], resourceIdToReorder: "E", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["U": 0, "V": 1, "W": 2, "X": 3]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["L": 0, "M": 1, "N": 2, "O": 3, "P": 4], resourceIdToReorder: "N", originalPosition: 2, newPosition: 1, expectedUpdatedIdsAtPositions: ["L": 0, "N": 1, "M": 2, "O": 3, "P": 4]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["D": 0, "E": 1, "F": 2, "G": 3, "H": 4], resourceIdToReorder: "D", originalPosition: 0, newPosition: 4, expectedUpdatedIdsAtPositions: ["E": 0, "F": 1, "G": 2, "H": 3, "D": 4]),
        ]
    )
    func reorderFavoritedResources(argument: ReorderTestArgument) async throws {
        
        let favoritedResourcesCache: FavoritedResourcesCache = try getFavoritedResourcesCache(
            addResources: argument.resourcesInRealmIdsAtPositions
        )
        
        let favoritedResources: [FavoritedResourceDataModel] = try await favoritedResourcesCache
            .reorderFavoritedResource(id: argument.resourceIdToReorder, originalPosition: argument.originalPosition, newPosition: argument.newPosition)
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition: Int = try #require(favoritedResources.first(where: { $0.id == expectedId })?.position)
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
}

extension FavoritedResourcesCacheTests {
    
    private func createFavoritedResources(resources: [String: Int]) -> [RealmFavoritedResource] {
        
        var resourceObjects: [RealmFavoritedResource] = Array()
        
        for (resourceId, resourcePosition) in resources {
            
            let dataModel = FavoritedResourceDataModel(
                id: resourceId,
                createdAt: Date(),
                position: resourcePosition
            )
            
            resourceObjects.append(RealmFavoritedResource.createNewFrom(model: dataModel))
        }
        
        return resourceObjects
    }
    
    private func getFavoritedResourcesCache(addResources: [String: Int]) throws -> FavoritedResourcesCache {
        
        let testsDiContainer: TestsDiContainer = try TestsDiContainer(
            realmFileName: String(describing: FavoritedResourcesCacheTests.self),
            addRealmObjects: createFavoritedResources(resources: addResources)
        )
        
        return testsDiContainer.dataLayer.getFavoritedResourcesRepository().cache
    }
}
