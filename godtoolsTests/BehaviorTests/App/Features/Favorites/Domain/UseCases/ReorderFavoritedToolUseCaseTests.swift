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
import RepositorySync

struct ReorderFavoritedToolUseCaseTests {

    struct TestArgument {
        let initialResources: [String: Int]
        let resourceIdToReorder: String
        let originalPosition: Int
        let newPosition: Int
        let expectedUpdatedIdsAtPositions: [String: Int]
    }

    @available(iOS 17.4, *)
    @Test(
       """
       Given: User is viewing all their favorite tools.
       When: A user drags a tool up or down in the list
       Then: The tool's position should update, and surrounding tool positions should update accordingly.
       """,
       arguments: [
        TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "C", originalPosition: 2, newPosition: 0, expectedUpdatedIdsAtPositions: ["C": 0, "A": 1, "B": 2, "D": 3, "E": 4]),
        TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "A", originalPosition: 0, newPosition: 4, expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "D": 2, "E": 3, "A": 4]),
        TestArgument(initialResources: ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4], resourceIdToReorder: "E", originalPosition: 4, newPosition: 2, expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "E": 2, "C": 3, "D": 4])
       ]
    )
    func testReorderFavorites(argument: TestArgument) async throws {
        
        let testsDiContainer: TestsDiContainer = try await getTestsDiContainer(
            addResources: argument.initialResources
        )
        
        let useCase = testsDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase()
        
        _ = try await useCase
            .execute(
                toolId: argument.resourceIdToReorder,
                originalPosition: argument.originalPosition,
                newPosition: argument.newPosition
            )
        
        let favoritedResources: [FavoritedResourceDataModel] = try await testsDiContainer.core.dataLayer.getFavoritedResourcesRepository().getFavoritedResourcesSortedByPosition()
        
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
    
    @available(iOS 17.4, *)
    private func getTestsDiContainer(addResources: [String: Int]) async throws -> TestsDiContainer {

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())
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
