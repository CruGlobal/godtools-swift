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
import RepositorySync

struct ToggleToolFavoritedUseCaseTests {
    
    struct TestArgument {
        let initialFavoritedResources: [String: Int]
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
        TestArgument(initialFavoritedResources: ["A": 0, "B": 1], resourceIdToToggle: "C", expectedUpdatedIdsAtPositions: ["C": 0, "A": 1, "B": 2]),
        TestArgument(initialFavoritedResources: [:], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: ["A": 0]),
        TestArgument(initialFavoritedResources: ["A": 0, "B": 1, "C": 2], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: ["B": 0, "C": 1]),
        TestArgument(initialFavoritedResources: ["A": 0], resourceIdToToggle: "A", expectedUpdatedIdsAtPositions: [:])
       ]
    )
    func testToggleToolFavorited(argument: TestArgument) async throws {
        
        let persistence = try await getPersistence(addObjects: createFavoritedResources(resources: argument.initialFavoritedResources))
        
        let repository = getRepository(persistence: persistence)
        
        let useCase = getUseCase(repository: repository)
                
        _ = try await useCase
            .execute(
                toolId: argument.resourceIdToToggle
            )
        
        let favoritedResources: [FavoritedResourceDataModel] = try await repository.getFavoritedResourcesSortedByPosition()
        
        for (expectedId, expectedPosition) in argument.expectedUpdatedIdsAtPositions {
            
            let favoritedResource: FavoritedResourceDataModel = try #require(favoritedResources.first(where: { $0.id == expectedId }))
            
            let actualPosition: Int = favoritedResource.position
            
            #expect(
                actualPosition == expectedPosition,
                "Expected position for resource \(expectedId) to be \(expectedPosition), but was \(actualPosition)"
            )
        }
    }
}

extension ToggleToolFavoritedUseCaseTests {
    
    private func getPersistence(addObjects: [FavoritedResourceDataModel]) async throws -> RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource> {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        let database = RealmDatabase(databaseConfig: databaseConfig)
        
        let persistence = RealmRepositorySyncPersistence(
            database: database,
            mapping: RealmFavoritedResourceMapping()
        )
        
        _ = try await persistence.writeObjects(externalObjects: addObjects)
        
        return persistence
    }
    
    private func getRepository(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>) -> FavoritedResourcesRepository {
        
        return FavoritedResourcesRepository(
            cache: FavoritedResourcesCache(persistence: persistence)
        )
    }
    
    private func getUseCase(repository: FavoritedResourcesRepository) -> ToggleToolFavoritedUseCase {
        
        return ToggleToolFavoritedUseCase(
            favoritedResourcesRepository: repository
        )
    }
    
    private func createFavoritedResources(resources: [String: Int]) -> [FavoritedResourceDataModel] {
        
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
