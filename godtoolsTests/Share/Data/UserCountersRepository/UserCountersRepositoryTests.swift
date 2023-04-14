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
    private let userCountersApi = UserCountersAPIMock()
    private var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
                
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
    
    func testFetchAndSyncRemoteUserCounters() throws {
        
        let counter1Id = "counter_1"
        let counter2Id = "counter_2"
        let counter3Id = "counter_3"
        
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter1Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter2Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter3Id))

        var error: Error?
        let expectation = expectation(description: "Fetch Remote User Counters")
        
        userCountersRepository.fetchRemoteUserCounters()
            .sink { completion in
                
                switch completion {
                case .finished:
                    break

                case .failure(let encounteredError):
                    error = encounteredError
                }

                expectation.fulfill()
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(error)
        
        let userCounter1 = userCountersRepository.getUserCounter(id: counter1Id)
        let userCounter2 = userCountersRepository.getUserCounter(id: counter2Id)
        let userCounter3 = userCountersRepository.getUserCounter(id: counter3Id)
                
        XCTAssertNotNil(userCounter1)
        XCTAssertNotNil(userCounter2)
        XCTAssertNotNil(userCounter3)
        
        XCTAssertEqual(userCounter1!.count, 1)
        XCTAssertEqual(userCounter2!.count, 2)
        XCTAssertEqual(userCounter3!.count, 3)
    }
    
    func testIncrementUserCounter() throws {

        let counterId = "counter_1"
        XCTAssertNil(userCountersRepository.getUserCounter(id: counterId))

        var error: Error?
        let expectation = expectation(description: "Increment User Counter")
        var updatedUserCounter: UserCounterDataModel?

        userCountersRepository.incrementCachedUserCounterBy1(id: counterId)
            .sink { completion in

                switch completion {
                case .finished:
                    break

                case .failure(let encounteredError):
                    error = encounteredError
                }

                expectation.fulfill()

            } receiveValue: { userCounter in

                updatedUserCounter = userCounter
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)

        XCTAssertNil(error)
        XCTAssertNotNil(updatedUserCounter)
        XCTAssertEqual(updatedUserCounter!.id, counterId)
        XCTAssertEqual(updatedUserCounter!.incrementValue, 1)
        XCTAssertEqual(updatedUserCounter!.latestCountFromAPI, 0)
    }
}
