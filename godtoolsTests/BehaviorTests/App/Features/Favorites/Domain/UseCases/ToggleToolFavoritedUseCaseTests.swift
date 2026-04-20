//
//  ToggleToolFavoritedUseCaseTests.swift
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
struct ToggleToolFavoritedUseCaseTests {
    
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
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(addResources: argument.resourcesInRealmIdsAtPositions)
                
        let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase = testsDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            toggleToolFavoritedUseCase
                .execute(
                    toolId: argument.resourceIdToToggle
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { _ in
                                       
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let favoritedResources: [FavoritedResourceDataModel] = try await testsDiContainer.dataLayer.getFavoritedResourcesRepository().cache.getFavoritedResourcesSortedByPosition()
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let actualPosition: Int = try #require(favoritedResources.first(where: { $0.id == expectedId })?.position)
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
}

extension ToggleToolFavoritedUseCaseTests {
    
    private func getTestsDiContainer(addResources: [String: Int]) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: ToggleToolFavoritedUseCaseTests.self),
            addRealmObjects: getFavoritedResources(resources: addResources)
        )
    }
    
    private func getFavoritedResources(resources: [String: Int]) -> [RealmFavoritedResource] {
        
        var resourceObjects = [RealmFavoritedResource]()
        
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
}
