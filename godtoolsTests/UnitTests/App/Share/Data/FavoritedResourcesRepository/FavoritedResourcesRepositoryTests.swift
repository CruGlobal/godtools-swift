//
//  FavoritedResourcesRepositoryTests.swift
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
struct FavoritedResourcesRepositoryTests {
    
    struct StoreTestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdsToAdd: [String]
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
        "Tools should be added to favorites and all resource positions updated in reserve order that they were added.",
        arguments: [
            StoreTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1], resourceIdsToAdd: ["C", "D", "E"], expectedUpdatedIdsAtPositions: ["C": 0, "D": 1, "E": 2, "A": 3, "B": 4]),
            StoreTestArgument(resourcesInRealmIdsAtPositions: [:], resourceIdsToAdd: ["A", "B", "C"], expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2]),
        ]
    )
    func testStoreFavoritedResources(argument: StoreTestArgument) async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase = try getRealmDatabase(resources: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
        
        var favoritedResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                favoritedResourcesRepository
                    .storeFavoritedResourcesPublisher(ids: argument.resourceIdsToAdd)
                    .sink(receiveValue: { _ in
                        
                        favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                            FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                        }
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
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
    func testDeleteFavoritedResource(argument: DeleteTestArgument) async throws {
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase = try getRealmDatabase(resources: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
        
        var remainingResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                favoritedResourcesRepository
                    .deleteFavoritedResourcePublisher(id: argument.resourceIdToDelete)
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { _ in
                        
                        let realm = realmDatabase.openRealm()
                        remainingResources = realm.objects(RealmFavoritedResource.self).map {
                            FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                        }
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }

        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition = remainingResources.first(where: { $0.id == expectedId })?.position
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition ?? -1)"
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
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3], resourceIdToReorder: "D", originalPosition: 3, newPosition: 0, expectedUpdatedIdsAtPositions: ["D": 0, "A": 1, "B": 2, "C": 3]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3], resourceIdToReorder: "B", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["A": 0, "C": 1, "B": 2, "D": 3]),
            ReorderTestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3], resourceIdToReorder: "E", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3])
        ]
    )
    func testReorderFavoritedResources(argument: ReorderTestArgument) async throws {
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase = try getRealmDatabase(resources: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
        
        var favoritedResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                favoritedResourcesRepository
                    .reorderFavoritedResourcePublisher(id: argument.resourceIdToReorder, originalPosition: argument.originalPosition, newPosition: argument.newPosition)
                    .sink { _ in
                        
                    } receiveValue: { _ in
                        
                        let realm = realmDatabase.openRealm()
                        
                        favoritedResources = realm.objects(RealmFavoritedResource.self).map {
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

extension FavoritedResourcesRepositoryTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: FavoritedResourcesRepositoryTests.self),
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


