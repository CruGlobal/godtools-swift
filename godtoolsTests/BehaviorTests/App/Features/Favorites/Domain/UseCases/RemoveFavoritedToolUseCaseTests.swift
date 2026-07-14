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
import RepositorySync

struct RemoveFavoritedToolUseCaseTests {
    
    struct TestArgument {
        let initialResources: [String: Int]
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
            TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "D": 2, "E": 3]),
            TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A": 0, "C": 1, "D": 2]),
            TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "E", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3]),
            TestArgument(initialResources: ["A": 0], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: [:]),
            TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToDelete: "F", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
        ]
    )
    func testRemoveFavoritedTool(argument: TestArgument) async throws {
                
        let testsDiContainer = try await getTestsDiContainer(addResources: argument.initialResources)
        
        let useCase = testsDiContainer.feature.favorites.domainLayer.getRemoveFavoritedToolUseCase()
        
        let remainingResources: [FavoritedResourceDataModel] = try await useCase.execute(toolId: argument.resourceIdToDelete)
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let resource: FavoritedResourceDataModel = try #require(remainingResources.first(where: { $0.id == expectedId }))
            
            let actualPosition: Int = resource.position
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
}

extension RemoveFavoritedToolUseCaseTests {
    
    private func getTestsDiContainer(addResources: [String: Int]) async throws -> TestsDiContainer {
                
        let testsDiContainer = try TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                realmDatabase: FakeRealmDatabase.createRealmDatabase()
            )
        )
        
        let favoritedResources = getFavoritedResources(resources: addResources)
        
        try await testsDiContainer.core.dataLayer.getFavoritedResourcesPersistence()
            .writeObjects(externalObjects: favoritedResources)
        
        return testsDiContainer
    }
    
    private func getFavoritedResources(resources: [String: Int]) -> [FavoritedResourceDataModel] {
        
        var favoritedResources = [FavoritedResourceDataModel]()
        
        for (resourceId, resourcePosition) in resources {
            
            let dataModel = FavoritedResourceDataModel(
                id: resourceId,
                createdAt: Date(),
                position: resourcePosition
            )
            
            favoritedResources.append(dataModel)
        }
        
        return favoritedResources
    }
}
