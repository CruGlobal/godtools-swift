//
//  FollowUpsServiceTests.swift
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
struct FollowUpsServiceTests {
        
    @Test()
    func postedFollowUpsWithErrorArePersisted() async throws {
                
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .failure(NSError.errorWithDescription(description: "error 1"))
        
        let followUpsService = FollowUpsService(
            api: MockFollowUpsApi(result: result),
            cache: cache
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        do {
            try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
        }
        catch _ {
            
        }
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedFollowUps().count
        
        #expect(count == 1)
    }
    
    @Test()
    func postedFollowUpsWithBadHttpStatusCodeArePersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400))
        
        let followUpsService = FollowUpsService(
            api: MockFollowUpsApi(result: result),
            cache: cache
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedFollowUps().count
        
        #expect(count == 1)
    }
    
    @Test()
    func postedFollowUpsWithSuccessHttpStatusCodeAreNotPersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200))
        
        let followUpsService = FollowUpsService(
            api: MockFollowUpsApi(result: result),
            cache: cache
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedFollowUps().count
        
        #expect(count == 0)
    }
    
    @Test()
    func postingFailedFollowUpsIfNeededAreRemovedFromTheLocalDatabase() async throws {
        
        let followUps = [
            RealmFollowUp.random(),
            RealmFollowUp.random(),
            RealmFollowUp.random(),
            RealmFollowUp.random(),
            RealmFollowUp.random(),
            RealmFollowUp.random()
        ]
        
        let cache = try getCache(addRealmObjects: followUps)
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200))
        
        let followUpsService = FollowUpsService(
            api: MockFollowUpsApi(result: result),
            cache: cache
        )
                
        try await followUpsService.postFailedFollowUpsIfNeeded(requestPriority: .high)
        
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getFailedFollowUps().count
        
        #expect(count == 0)
    }
}

extension FollowUpsServiceTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject]) throws -> TestsDiContainer {
        return try TestsDiContainer(
            realmFileName: String(describing: FollowUpsServiceTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getCache(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> FailedFollowUpsCache {
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: addRealmObjects)
        
        let cache = FailedFollowUpsCache(realmDatabase: testsDiContainer.dataLayer.getSharedRealmDatabase())
        
        return cache
    }
}
