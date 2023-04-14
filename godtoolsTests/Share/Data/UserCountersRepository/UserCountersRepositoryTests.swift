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
    
    override func setUp() {
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
    
    func testSyncNewRemoteUserCounters() throws {
        
        let counter1Id = "counter_1"
        let counter2Id = "counter_2"
        let counter3Id = "counter_3"
        
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter1Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter2Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter3Id))

        var error: Error?
        let expectation = expectation(description: "Fetch Remote User Counters")
        var syncedDataModels = [UserCounterDataModel]()
        
        userCountersRepository.fetchRemoteUserCounters()
            .sink { completion in
                
                switch completion {
                case .finished:
                    break

                case .failure(let encounteredError):
                    error = encounteredError
                }

                expectation.fulfill()
                
            } receiveValue: { syncedUserCounters in
                
                syncedDataModels = syncedUserCounters
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(error)
        
        let counter1DataModel = syncedDataModels.first(where: { $0.id == counter1Id })
        let counter2DataModel = syncedDataModels.first(where: { $0.id == counter2Id })
        let counter3DataModel = syncedDataModels.first(where: { $0.id == counter3Id })

        XCTAssertNotNil(counter1DataModel)
        XCTAssertNotNil(counter2DataModel)
        XCTAssertNotNil(counter3DataModel)

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, 10)
        XCTAssertEqual(counter1DataModel!.incrementValue, 0)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, 20)
        XCTAssertEqual(counter2DataModel!.incrementValue, 0)
    }
    
    func testSyncExistingRemoteUserCounters() throws {
        
        let counter1Id = "counter_1"
        let counter2Id = "counter_2"
        
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter1Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter2Id))
        
        let incrementCounter1Expectation = expectation(description: "Increment Counter 1 Once")
        let incrementCounter2Expectation = expectation(description: "Increment Counter 2 Twice")
        
        userCountersRepository.incrementCachedUserCounterBy1(id: counter1Id)
            .sink { _ in
                
                incrementCounter1Expectation.fulfill()
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        
        userCountersRepository.incrementCachedUserCounterBy1(id: counter2Id)
            .flatMap { _ in
                
                return self.userCountersRepository.incrementCachedUserCounterBy1(id: counter2Id)
            }
            .sink { _ in
                
                incrementCounter2Expectation.fulfill()
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)

        wait(for: [incrementCounter1Expectation, incrementCounter2Expectation], timeout: 10)

        var error: Error?
        let fetchAndSyncExpectation = expectation(description: "Fetch Existing Remote User Counters")
        var syncedDataModels = [UserCounterDataModel]()
        
        userCountersRepository.fetchRemoteUserCounters()
            .sink { completion in
                
                switch completion {
                case .finished:
                    break

                case .failure(let encounteredError):
                    error = encounteredError
                }

                fetchAndSyncExpectation.fulfill()
                
            } receiveValue: { syncedUserCounters in
                
                syncedDataModels = syncedUserCounters
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(error)
        
        let counter1DataModel = syncedDataModels.first(where: { $0.id == counter1Id })
        let counter2DataModel = syncedDataModels.first(where: { $0.id == counter2Id })

        XCTAssertNotNil(counter1DataModel)
        XCTAssertNotNil(counter2DataModel)

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, 10)
        XCTAssertEqual(counter1DataModel!.incrementValue, 1)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, 20)
        XCTAssertEqual(counter2DataModel!.incrementValue, 2)
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
