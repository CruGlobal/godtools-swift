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
    private var userCountersApi: UserCountersAPIMock!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        userCountersApi = UserCountersAPIMock()
        cancellables = Set<AnyCancellable>()
        
        let realmDatabase = RealmDatabase(databaseConfiguration: RealmDatabaseMockConfiguration())
        let userCountersCacheSync = RealmUserCountersCacheSync(realmDatabase: realmDatabase)
        let userCountersCache = RealmUserCountersCache(realmDatabase: realmDatabase, userCountersSync: userCountersCacheSync)
        
        let remoteUserCountersSync = RemoteUserCountersSync(api: userCountersApi, cache: userCountersCache)
        
        userCountersRepository = UserCountersRepository(
            api: userCountersApi,
            cache: userCountersCache,
            remoteUserCountersSync: remoteUserCountersSync
        )
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
    func testGetUserCounter() throws {
        
        let counter1 = UserCounterDomainModel(id: "counter_1", count: 1)
        let counter2 = UserCounterDomainModel(id: "counter_2", count: 2)
        
        cacheMockCounters([counter1, counter2])
        
        let cachedCounter1 = userCountersRepository.getUserCounter(id: counter1.id)
        let cachedCounter2 = userCountersRepository.getUserCounter(id: counter2.id)
        
        XCTAssertNotNil(cachedCounter1)
        XCTAssertNotNil(cachedCounter2)
        
        XCTAssertEqual(cachedCounter1!.id, counter1.id)
        XCTAssertEqual(cachedCounter1!.count, counter1.count)
        XCTAssertEqual(cachedCounter2!.id, counter2.id)
        XCTAssertEqual(cachedCounter2!.count, counter2.count)
    }
    
    func testFetchRemoteUserCounters() throws {
        
        let counter1Id = "counter_1"
        let counter2Id = "counter_2"
        let counter3Id = "counter_3"
        
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter1Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter2Id))
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter3Id))
        
        let latestCountFromMockAPI1 = 10
        let latestCountFromMockAPI2 = 20
        let latestCountFromMockAPI3 = 30
        
        userCountersApi.setMockFetchResponse(fetchedCounters: [
            UserCounterDecodable(id: counter1Id, count: latestCountFromMockAPI1),
            UserCounterDecodable(id: counter2Id, count: latestCountFromMockAPI2),
            UserCounterDecodable(id: counter3Id, count: latestCountFromMockAPI3)
        ])

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

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, latestCountFromMockAPI1)
        XCTAssertEqual(counter1DataModel!.incrementValue, 0)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, latestCountFromMockAPI2)
        XCTAssertEqual(counter2DataModel!.incrementValue, 0)
        XCTAssertEqual(counter3DataModel!.latestCountFromAPI, latestCountFromMockAPI3)
        XCTAssertEqual(counter3DataModel!.incrementValue, 0)
    }
    
    func testFetchRemoteUserCountersWithExistingLocalCounters() throws {
        
        let counter1 = UserCounterDomainModel(id: "counter_1", count: 2)
        let counter2 = UserCounterDomainModel(id: "counter_2", count: 4)
        
        cacheMockCounters([counter1, counter2])
        
        let latestCountFromMockAPI1 = 5
        let latestCountFromMockAPI2 = 8
        
        userCountersApi.setMockFetchResponse(fetchedCounters: [
            UserCounterDecodable(id: counter1.id, count: latestCountFromMockAPI1),
            UserCounterDecodable(id: counter2.id, count: latestCountFromMockAPI2),
        ])

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
        
        let counter1DataModel = syncedDataModels.first(where: { $0.id == counter1.id })
        let counter2DataModel = syncedDataModels.first(where: { $0.id == counter2.id })
        
        XCTAssertNotNil(counter1DataModel)
        XCTAssertNotNil(counter2DataModel)

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, latestCountFromMockAPI1)
        XCTAssertEqual(counter1DataModel!.incrementValue, counter1.count)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, latestCountFromMockAPI2)
        XCTAssertEqual(counter2DataModel!.incrementValue, counter2.count)
        
        let counter1DomainModel = userCountersRepository.getUserCounter(id: counter1.id)
        let counter2DomainModel = userCountersRepository.getUserCounter(id: counter2.id)
        
        XCTAssertNotNil(counter1DomainModel)
        XCTAssertNotNil(counter2DomainModel)
        XCTAssertEqual(counter1DomainModel!.count, counter1.count + latestCountFromMockAPI1)
        XCTAssertEqual(counter2DomainModel!.count, counter2.count + latestCountFromMockAPI2)
    }
    
    func testSyncUpdatedUserCountersWithRemote() throws {
        
        // number of changes expected: 2 to cache mock counters + 2 for sync
        let syncUpdateCompleteExpectation = makeExpectationForUserCounterChangesToOccur(numberOfChanges: 4)
        
        let counter1 = UserCounterDomainModel(id: "counter_1", count: 3)
        let counter2 = UserCounterDomainModel(id: "counter_2", count: 4)
        
        cacheMockCounters([counter1, counter2])
        
        let counter1RemoteCount = 7
        let counter2RemoteCount = 12
        
        userCountersApi.setMockRemoteCountResponse(countValues: [counter1RemoteCount, counter2RemoteCount])
        
        userCountersRepository.syncUpdatedUserCountersWithRemote()
        
        waitForExpectations(timeout: 10)
        
        let updatedCounter1 = userCountersRepository.getUserCounter(id: counter1.id)
        let updatedCounter2 = userCountersRepository.getUserCounter(id: counter2.id)
        
        XCTAssertNotNil(updatedCounter1)
        XCTAssertNotNil(updatedCounter2)
        
        XCTAssertEqual(updatedCounter1!.count, counter1RemoteCount + counter1.count)
        XCTAssertEqual(updatedCounter2!.count, counter2RemoteCount + counter2.count)
    }
}

// MARK: - Private

extension UserCountersRepositoryTests {
    
    private func cacheMockCounters(_ counters: [UserCounterDomainModel]) {
        
        for counter in counters {
            cacheMockCounter(counter)
        }
    }
    
    private func cacheMockCounter(_ counter: UserCounterDomainModel) {
        
        XCTAssertNil(userCountersRepository.getUserCounter(id: counter.id))
                
        for i in 1...counter.count {
            
            let expectation = expectation(description: "Increment \(i) for Counter \(counter.id)")
            
            userCountersRepository.incrementCachedUserCounterBy1(id: counter.id)
                .sink { _ in
                    
                    expectation.fulfill()
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
        
            wait(for: [expectation], timeout: 10)
        }
    }
    
    private func makeExpectationForUserCounterChangesToOccur(numberOfChanges: Int) -> XCTestExpectation {
        
        let userCounterChangesCompleteExpectation = expectation(description: "User Counter Changes Complete")
        
        var userCounterChangedHitCount = 0

        userCountersRepository.getUserCountersChanged(reloadFromRemote: false)
            .sink { _ in
                
            } receiveValue: { _ in
                
                userCounterChangedHitCount += 1
                
                if userCounterChangedHitCount == numberOfChanges {
                    
                    userCounterChangesCompleteExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        return userCounterChangesCompleteExpectation
    }
}
