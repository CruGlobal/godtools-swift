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

@Suite(.serialized)
struct ResourceViewsServiceTests {
        
    @Test()
    func postedResourceViewsWithErrorArePersisted() async throws {
                
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .failure(NSError.errorWithDescription(description: "error 1"))
        
        let resourceViewsService = ResourceViewsService(
            api: MockResourceViewsApi(result: result),
            failedResourceViewsCache: cache
        )
                
        do {
            try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
        }
        catch _ {
            
        }
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedResourceViews().count
        
        #expect(count == 1)
    }
    
    @Test()
    func postedResourceViewsWithBadHttpStatusCodeArePersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400))
        
        let resourceViewsService = ResourceViewsService(
            api: MockResourceViewsApi(result: result),
            failedResourceViewsCache: cache
        )
                
        try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedResourceViews().count
        
        #expect(count == 1)
    }
    
    @Test()
    func postedResourceViewsWithSuccessHttpStatusCodeAreNotPersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200))
        
        let resourceViewsService = ResourceViewsService(
            api: MockResourceViewsApi(result: result),
            failedResourceViewsCache: cache
        )
                
        try await resourceViewsService.postNewResourceView(resourceId: "1", requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedResourceViews().count
        
        #expect(count == 0)
    }
    
    @Test()
    func postingFailedResourceViewsIfNeededAreRemovedFromTheLocalDatabase() async throws {
        
        let resourceViews = [
            RealmResourceView.random(),
            RealmResourceView.random(),
            RealmResourceView.random(),
            RealmResourceView.random(),
            RealmResourceView.random(),
            RealmResourceView.random()
        ]
        
        let cache = try getCache(addRealmObjects: resourceViews)
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200))
        
        let resourceViewsService = ResourceViewsService(
            api: MockResourceViewsApi(result: result),
            failedResourceViewsCache: cache
        )
                
        try await resourceViewsService.postFailedResourceViewsIfNeeded(requestPriority: .high)
        
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedResourceViews().count
        
        #expect(count == 0)
    }
}

extension ResourceViewsServiceTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject]) throws -> TestsDiContainer {
        return try TestsDiContainer(
            realmFileName: String(describing: ResourceViewsServiceTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getCache(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> FailedResourceViewsCache {
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: addRealmObjects)
        
        let cache = FailedResourceViewsCache(realmDatabase: testsDiContainer.dataLayer.getSharedRealmDatabase())
        
        return cache
    }
}
