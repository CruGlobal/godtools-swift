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

struct FavoritedResourcesRepositoryTests {
    
    struct TestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdsToUpdate: [String]
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    
    @Test(
        "Tools should be added to favorites and all resource positions updated in reserve order that they were added.",
        arguments: [
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1], resourceIdsToUpdate: ["C", "D", "E"], expectedUpdatedIdsAtPositions: ["C": 0, "D": 1, "E": 2, "A": 3, "B": 4]),
            TestArgument(resourcesInRealmIdsAtPositions: [:], resourceIdsToUpdate: ["A", "B", "C"], expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2]),
        ]
    )
    @MainActor func testStoreFavoritedResources(argument: TestArgument) async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase = Self.getConfiguredRealmDatabase(with: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
        
        var favoritedResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            favoritedResourcesRepository.storeFavoritedResourcesPublisher(ids: argument.resourceIdsToUpdate)
                .sink(receiveValue: { _ in
                    
                    favoritedResources = realmDatabase.openRealm().objects(RealmFavoritedResource.self).map {
                        FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                    }
                    
                    confirmation()
                })
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
    
    @Test(
        "Deleting a favorited tool should remove it from favorites and update positions of remaining resources.",
        arguments: [
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdsToUpdate: ["A"], expectedUpdatedIdsAtPositions: ["B": 0, "C": 1]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdsToUpdate: ["B"], expectedUpdatedIdsAtPositions: ["A":0, "C":1]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2], resourceIdsToUpdate: ["C"], expectedUpdatedIdsAtPositions: ["A": 0, "B": 1]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0], resourceIdsToUpdate: ["A"], expectedUpdatedIdsAtPositions: [:])
        ]
    )
    @MainActor func testDeleteFavoritedResourcePublisher(argument: TestArgument) async {
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase = Self.getConfiguredRealmDatabase(with: argument.resourcesInRealmIdsAtPositions)
        let favoritedResourcesRepository = FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase))
        
        var remainingResources: [FavoritedResourceDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            favoritedResourcesRepository.deleteFavoritedResourcePublisher(id: argument.resourceIdsToUpdate.first!)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { _ in
                    
                    let realm = realmDatabase.openRealm()
                    remainingResources = realm.objects(RealmFavoritedResource.self).map {
                        FavoritedResourceDataModel(id: $0.resourceId, createdAt: $0.createdAt, position: $0.position)
                    }
                    
                    confirmation()
                })
                .store(in: &cancellables)
        }
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition = remainingResources.first(where: { $0.id == expectedId })?.position
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition ?? -1)"
            )
        }
    }
    
//    @MainActor func testReorderFavoritedResources() async {
//
//    }
}

extension FavoritedResourcesRepositoryTests {
    
    private static func getConfiguredRealmDatabase(with resources: [String: Int]) -> RealmDatabase {
        
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            let resource = RealmFavoritedResource(createdAt: Date(), resourceId: resourceId, position: resourcePosition)
            resourceObjects.append(resource)
        }
        
        return TestsInMemoryRealmDatabase(addObjectsToDatabase: resourceObjects)
    }
}


