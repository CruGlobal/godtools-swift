//
//  ResourceViewsServiceTests.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RequestOperation
import RepositorySync

struct ResourceViewsServiceTests {
        
    @available(iOS 17.4, *)
    @Test()
    func postedResourceViewsWithErrorArePersisted() async throws {
                
        let persistence = try await getPersistence(addObjects: [])
        
        let resourceViewsService = getResourceViewsService(
            apiResult: .failure(NSError.errorWithDescription(description: "error 1")),
            persistence: persistence
        )
             
        do {
            try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
        }
        catch _ {
            
        }
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 1)
    }
    
    @available(iOS 17.4, *)
    @Test()
    func postedResourceViewsWithBadHttpStatusCodeArePersisted() async throws {
        
        let persistence = try await getPersistence(addObjects: [])
        
        let resourceViewsService = getResourceViewsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400)),
            persistence: persistence
        )
        
        try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 1)
    }
    
    @available(iOS 17.4, *)
    @Test()
    func postedResourceViewsWithSuccessHttpStatusCodeAreNotPersisted() async throws {
        
        let persistence = try await getPersistence(addObjects: [])
        
        let resourceViewsService = getResourceViewsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200)),
            persistence: persistence
        )
                        
        try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 0)
    }
    
    @available(iOS 17.4, *)
    @Test()
    func postingFailedResourceViewsIfNeededAreRemovedFromTheLocalDatabase() async throws {
        
        let resourceViews = [
            ResourceViewDataModel.random(),
            ResourceViewDataModel.random(),
            ResourceViewDataModel.random(),
            ResourceViewDataModel.random(),
            ResourceViewDataModel.random()
        ]
        
        let persistence = try await getPersistence(addObjects: resourceViews)
        
        let resourceViewsService = getResourceViewsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200)),
            persistence: persistence
        )
                        
        try await resourceViewsService.postFailedResourceViewsIfNeeded(requestPriority: .high)
                
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 0)
    }
}

extension ResourceViewsServiceTests {
        
    @available(iOS 17.4, *)
    private func getPersistence(addObjects: [ResourceViewDataModel]) async throws -> SwiftRepositorySyncPersistence<ResourceViewDataModel, ResourceViewDataModel, SwiftResourceView> {

        let database = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let persistence = SwiftRepositorySyncPersistence(
            database: database,
            mapping: SwiftResourceViewMapping()
        )

        _ = try await persistence.writeObjects(externalObjects: addObjects)

        return persistence
    }
    
    private func getResourceViewsService(apiResult: Result<RequestDataResponse, Error>, persistence: any Persistence<ResourceViewDataModel, ResourceViewDataModel>) -> ResourceViewsService {
                
        return ResourceViewsService(
            api: FakeResourceViewsApi(result: apiResult),
            cache: FailedResourceViewsCache(persistence: persistence)
        )
    }
}
