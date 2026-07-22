//
//  FavoritedResourcesCacheTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData
import RepositorySync

struct FavoritedResourcesCacheTests {

    struct StoreTestArgument {
        let initialResources: [String: Int]
        let resourceIdsToAdd: [String]
        let expectedUpdatedIdsAtPositions: [String: Int]
    }

    struct DeleteTestArgument {
        let initialResources: [String: Int]
        let resourceIdToDelete: String
        let expectedUpdatedIdsAtPositions: [String: Int]
    }

    struct ReorderTestArgument {
        let initialResources: [String: Int]
        let resourceIdToReorder: String
        let originalPosition: Int
        let newPosition: Int
        let expectedUpdatedIdsAtPositions: [String: Int]
    }

    // MARK: - Get Favorited Resources

    @available(iOS 17.4, *)
    @Test
    func getFavoritedResourcesSortedByPosition() async throws {

        let cache = try getCache(
            initialResources: ["C": 2, "A": 0, "B": 1]
        )

        let favoritedResources: [FavoritedResourceDataModel] = try await cache.getFavoritedResourcesSortedByPosition()

        #expect(favoritedResources.map { $0.id } == ["A", "B", "C"])
    }

    // MARK: - Store Favorited Resources

    @available(iOS 17.4, *)
    @Test(
        "Tools should be added to favorites and all resource positions updated in reverse order that they were added.",
        arguments: [
            StoreTestArgument(initialResources: ["A": 0, "B": 1], resourceIdsToAdd: ["C", "D", "E"], expectedUpdatedIdsAtPositions: ["C": 0, "D": 1, "E": 2, "A": 3, "B": 4]),
            StoreTestArgument(initialResources: [:], resourceIdsToAdd: ["A", "B", "C"], expectedUpdatedIdsAtPositions: ["A": 0, "B": 1, "C": 2])
        ]
    )
    func storeFavoritedResources(argument: StoreTestArgument) async throws {

        let cache = try getCache(
            initialResources: argument.initialResources
        )

        let favoritedResources: [FavoritedResourceDataModel] = try await cache
            .storeFavoritedResources(ids: argument.resourceIdsToAdd)

        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {

            let favoritedResource: FavoritedResourceDataModel = try #require(favoritedResources.first(where: { $0.id == expectedId }))

            #expect(
                favoritedResource.position == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(favoritedResource.position)"
            )
        }
    }

    // MARK: - Delete Favorited Resource

    @available(iOS 17.4, *)
    @Test(
        "Deleting a favorited tool should remove it from favorites and update positions of remaining resources.",
        arguments: [
            DeleteTestArgument(initialResources: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1]),
            DeleteTestArgument(initialResources: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A": 0, "C": 1]),
            DeleteTestArgument(initialResources: ["A": 0, "B": 1, "C": 2], resourceIdToDelete: "C", expectedUpdatedIdsAtPositions: ["A": 0, "B": 1]),
            DeleteTestArgument(initialResources: ["A": 0], resourceIdToDelete: "A", expectedUpdatedIdsAtPositions: [:]),
            DeleteTestArgument(initialResources: ["A": 0], resourceIdToDelete: "B", expectedUpdatedIdsAtPositions: ["A": 0])
        ]
    )
    func deleteFavoritedResource(argument: DeleteTestArgument) async throws {

        let cache = try getCache(
            initialResources: argument.initialResources
        )

        let remainingResources: [FavoritedResourceDataModel] = try await cache
            .deleteFavoritedResource(id: argument.resourceIdToDelete)

        #expect(remainingResources.count == argument.expectedUpdatedIdsAtPositions.count)

        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {

            let favoritedResource: FavoritedResourceDataModel = try #require(remainingResources.first(where: { $0.id == expectedId }))

            #expect(
                favoritedResource.position == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(favoritedResource.position)"
            )
        }
    }

    // MARK: - Reorder Favorited Resource

    @available(iOS 17.4, *)
    @Test(
        "Reordering a favorited tool should move the tool to the new position, and update the surrounding tools positions accordingly.",
        arguments: [
            ReorderTestArgument(initialResources: ["A": 0, "B": 1, "C": 2], resourceIdToReorder: "A", originalPosition: 0, newPosition: 2, expectedUpdatedIdsAtPositions: ["B": 0, "C": 1, "A": 2]),
            ReorderTestArgument(initialResources: ["H": 0, "I": 1, "J": 2, "K": 3], resourceIdToReorder: "K", originalPosition: 3, newPosition: 0, expectedUpdatedIdsAtPositions: ["K": 0, "H": 1, "I": 2, "J": 3]),
            ReorderTestArgument(initialResources: ["Q": 0, "R": 1, "S": 2, "T": 3], resourceIdToReorder: "R", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["Q": 0, "S": 1, "R": 2, "T": 3]),
            ReorderTestArgument(initialResources: ["U": 0, "V": 1, "W": 2, "X": 3], resourceIdToReorder: "E", originalPosition: 1, newPosition: 2, expectedUpdatedIdsAtPositions: ["U": 0, "V": 1, "W": 2, "X": 3]),
            ReorderTestArgument(initialResources: ["L": 0, "M": 1, "N": 2, "O": 3, "P": 4], resourceIdToReorder: "N", originalPosition: 2, newPosition: 1, expectedUpdatedIdsAtPositions: ["L": 0, "N": 1, "M": 2, "O": 3, "P": 4]),
            ReorderTestArgument(initialResources: ["D": 0, "E": 1, "F": 2, "G": 3, "H": 4], resourceIdToReorder: "D", originalPosition: 0, newPosition: 4, expectedUpdatedIdsAtPositions: ["E": 0, "F": 1, "G": 2, "H": 3, "D": 4])
        ]
    )
    func reorderFavoritedResources(argument: ReorderTestArgument) async throws {

        let cache = try getCache(
            initialResources: argument.initialResources
        )

        let favoritedResources: [FavoritedResourceDataModel] = try await cache
            .reorderFavoritedResource(
                id: argument.resourceIdToReorder,
                originalPosition: argument.originalPosition,
                newPosition: argument.newPosition
            )

        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {

            let favoritedResource: FavoritedResourceDataModel = try #require(favoritedResources.first(where: { $0.id == expectedId }))

            #expect(
                favoritedResource.position == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(favoritedResource.position).  Favorited resources: \(favoritedResources.map { $0.id })"
            )
        }
    }
}

// MARK: - Test Helpers

extension FavoritedResourcesCacheTests {

    @available(iOS 17.4, *)
    private func getCache(initialResources: [String: Int]) throws -> FavoritedResourcesCache {

        let testsAppConfig = TestsAppConfig(
            swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase(addObjects: getSwiftDatabaseObjects(resources: initialResources))
        )

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.core.dataLayer.getFavoritedResourcesCache()
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects(resources: [String: Int]) -> [SwiftFavoritedResource] {
        return createFavoritedResources(resources: resources).map { SwiftFavoritedResource.createNewFrom(model: $0) }
    }

    private func createFavoritedResources(resources: [String: Int]) -> [FavoritedResourceDataModel] {

        return resources.map { (id: String, position: Int) in
            FavoritedResourceDataModel.random(id: id, position: position)
        }
    }
}
