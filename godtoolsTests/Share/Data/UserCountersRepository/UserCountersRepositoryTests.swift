//
//  UserCountersRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import Combine

final class UserCountersRepositoryTests: XCTestCase {

    private var userCountersRepository: UserCountersRepository!
    private var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let userCountersApi = UserCountersAPIMock()
        
        let realmDatabase = RealmDatabase(databaseConfiguration: RealmDatabaseMockConfiguration())
        let userCountersCacheSync = RealmUserCountersCacheSync(realmDatabase: realmDatabase)
        let userCountersCache = RealmUserCountersCache(realmDatabase: realmDatabase, userCountersSync: userCountersCacheSync)
        
        let remoteUserCountersSync = RemoteUserCountersSync(api: userCountersApi, cache: userCountersCache)
        
        userCountersRepository = UserCountersRepository(
            api: UserCountersAPIMock(),
            cache: userCountersCache,
            remoteUserCountersSync: remoteUserCountersSync
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIncrementUserCounter() throws {
        
        // Given:
        
        let counterId = "counter_1"
        XCTAssertNil(userCountersRepository.getUserCounter(id: counterId))
        
        // When
        
//        var updatedUserCounter: UserCounterDataModel
//        var error: Error?
//        let expectation = self.expectation(description: "Increment User Counter")
                        
//        userCountersRepository.incrementCachedUserCounterBy1(id: counterId)
//            .sink(receiveCompletion: { (completion: Combine.Subscribers.Completion<Error>) in
//                
//                switch completion {
//                case .finished:
//                    break
//                    
//                case .failure(let encounteredError):
//                    error = encounteredError
//                }
//                
//                expectation.fulfill()
//                
//            }, receiveValue: { userCounter in
//                
//                updatedUserCounter = userCounter
//            })
//            .store(in: &cancellables)

        
        // Then
        
        
    }
}
