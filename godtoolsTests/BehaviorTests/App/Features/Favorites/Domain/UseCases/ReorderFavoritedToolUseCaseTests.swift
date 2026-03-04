//
//  ReorderFavoritedToolUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync

@Suite(.serialized)
struct ReorderFavoritedToolUseCaseTests {

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
    func testReorderFavorites(argument: TestArgument) async throws {
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(
            addResources: argument.resourcesInRealmIdsAtPositions
        )
        
        let reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase = testsDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                reorderFavoritedToolUseCase
                    .execute(
                        toolId: argument.resourceIdToReorder,
                        originalPosition: argument.originalPosition,
                        newPosition: argument.newPosition
                    )
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        
                    } receiveValue: { (favoritedResources: [ReorderFavoritedToolDomainModel]) in
                                                
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        let favoritedResources: [FavoritedResourceDataModel] = try await testsDiContainer.dataLayer.getFavoritedResourcesRepository().cache.getFavoritedResourcesSortedByPosition()
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition = favoritedResources.first(where: { $0.id == expectedId })?.position
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
}

extension ReorderFavoritedToolUseCaseTests {
    
    private func getTestsDiContainer(addResources: [String: Int]) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: ReorderFavoritedToolUseCaseTests.self),
            addRealmObjects: getFavoritedResources(resources: addResources)
        )
    }
    
    private func getFavoritedResources(resources: [String: Int]) -> [RealmFavoritedResource] {
        
        var resourceObjects = [RealmFavoritedResource]()
        
        for (resourceId, resourcePosition) in resources {
            
            let dataModel = FavoritedResourceDataModel(id: resourceId, createdAt: Date(), position: resourcePosition)
            
            resourceObjects.append(RealmFavoritedResource.createNewFrom(interface: dataModel))
        }
        
        return resourceObjects
    }
}
