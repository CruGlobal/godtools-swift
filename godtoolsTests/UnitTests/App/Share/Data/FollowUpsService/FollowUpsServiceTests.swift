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

struct FollowUpsServiceTests {
        
    @Test()
    func postedFollowUpsWithErrorArePersisted() async throws {
                
        let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel> = try await getPersistence(addFollowUps: [])
        
        let followUpsService = getFollowUpsService(
            apiResult: .failure(NSError.errorWithDescription(description: "error 1")),
            persistence: persistence
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        do {
            try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
        }
        catch _ {
            
        }
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 1)
    }
    
    @Test()
    func postedFollowUpsWithBadHttpStatusCodeArePersisted() async throws {
        
        let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel> = try await getPersistence(addFollowUps: [])
        
        let followUpsService = getFollowUpsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400)),
            persistence: persistence
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 1)
    }
    
    @Test()
    func postedFollowUpsWithSuccessHttpStatusCodeAreNotPersisted() async throws {
        
        let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel> = try await getPersistence(addFollowUps: [])
        
        let followUpsService = getFollowUpsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200)),
            persistence: persistence
        )
        
        let followUp = FollowUp(name: "", email: "", destinationId: 0, languageId: 0)
        
        try await followUpsService.postFollowUp(followUp: followUp, requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 0)
    }
    
    @Test()
    func postingFailedFollowUpsIfNeededAreRemovedFromTheLocalDatabase() async throws {
        
        let followUps = [
            FollowUpDataModel.random(),
            FollowUpDataModel.random(),
            FollowUpDataModel.random(),
            FollowUpDataModel.random(),
            FollowUpDataModel.random()
        ]
        
        let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel> = try await getPersistence(addFollowUps: followUps)
        
        let followUpsService = getFollowUpsService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200)),
            persistence: persistence
        )
                        
        try await followUpsService.postFailedFollowUpsIfNeeded(requestPriority: .high)
                
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 0)
    }
}

extension FollowUpsServiceTests {
    
    private func getPersistence(addFollowUps: [FollowUpDataModel]) async throws -> RealmRepositorySyncPersistence<FollowUpDataModel, FollowUpDataModel, RealmFollowUp> {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        let database = RealmDatabase(databaseConfig: databaseConfig)
        
        let persistence = RealmRepositorySyncPersistence(
            database: database,
            mapping: RealmFollowUpMapping()
        )
        
        _ = try await persistence.writeObjects(externalObjects: addFollowUps)
        
        return persistence
    }
    
    private func getFollowUpsService(apiResult: Result<RequestDataResponse, Error>, persistence: any Persistence<FollowUpDataModel, FollowUpDataModel>) -> FollowUpsService {
                
        return FollowUpsService(
            api: FakeFollowUpsApi(result: apiResult),
            cache: FailedFollowUpsCache(persistence: persistence)
        )
    }
}
