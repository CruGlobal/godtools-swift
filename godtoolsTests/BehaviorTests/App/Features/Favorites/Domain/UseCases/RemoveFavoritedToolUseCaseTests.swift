//
//  RemoveFavoritedToolUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync
import RealmSwift

@Suite(.serialized)
struct RemoveFavoritedToolUseCaseTests {
    
    struct TestArgument {
        let resourcesInRealmIdsAtPositions: [String: Int]
        let resourceIdToDelete: String
        let expectedUpdatedIdsAtPositions: [String: Int]
    }
    @Test(
        """
        Given: User is viewing all their favorite tools.
        When: A user unfavorites a tool
        Then: The tool should be removed from the repo, and tools listed after should be moved up one position.
        """,
        arguments: [
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "D": 2, "E": 3]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A": 0, "C": 1, "D": 2]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "E", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: [:]),
            TestArgument(resourcesInRealmIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "F", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
        ]
    )
    func testRemoveFavoritedTool(argument: TestArgument) async throws {
        
        let realmObjects: [IdentifiableRealmObject] = getRealmObjects(with: argument.resourcesInRealmIdsAtPositions)
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: realmObjects)
        
        let realmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        
        let removeFavoritedToolUseCase = RemoveFavoritedToolUseCase(favoritedResourcesRepository: FavoritedResourcesRepository(cache: RealmFavoritedResourcesCache(realmDatabase: realmDatabase)))
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var remainingResources: [FavoritedResourceDataModel] = Array()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                removeFavoritedToolUseCase
                    .execute(
                        toolId: argument.resourceIdToDelete
                    )
                    .sink(receiveValue: { _ in
                        
                        let realm: Realm = realmDatabase.openRealm()
                        
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
}

extension RemoveFavoritedToolUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: RemoveFavoritedToolUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getRealmObjects(with resources: [String: Int]) -> [IdentifiableRealmObject] {
        
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            let resource = RealmFavoritedResource(createdAt: Date(), resourceId: resourceId, position: resourcePosition)
            resourceObjects.append(resource)
        }
        
        return resourceObjects
    }
}
