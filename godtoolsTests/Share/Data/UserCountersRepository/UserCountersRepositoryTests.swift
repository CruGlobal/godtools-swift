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

        // Setup
        
        let counterId = "counter_1"
        assertLocalCounterIsNil(counterId)

        // Perform
        
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

        // Assert
        
        XCTAssertNil(error)
        XCTAssertNotNil(updatedUserCounter)
        XCTAssertEqual(updatedUserCounter!.id, counterId)
        XCTAssertEqual(updatedUserCounter!.incrementValue, 1)
        XCTAssertEqual(updatedUserCounter!.latestCountFromAPI, 0)
    }
    
    func testGetUserCounter() throws {
        
        // Setup
        
        let counter1 = UserCounterDomainModel(id: "counter_1", count: 1)
        let counter2 = UserCounterDomainModel(id: "counter_2", count: 2)
        
        cacheMockCounters([counter1, counter2])
        
        // Perform
        
        let cachedCounter1 = userCountersRepository.getUserCounter(id: counter1.id)
        let cachedCounter2 = userCountersRepository.getUserCounter(id: counter2.id)
        
        // Assert
        
        XCTAssertNotNil(cachedCounter1)
        XCTAssertNotNil(cachedCounter2)
        
        XCTAssertEqual(cachedCounter1!.id, counter1.id)
        XCTAssertEqual(cachedCounter1!.count, counter1.count)
        XCTAssertEqual(cachedCounter2!.id, counter2.id)
        XCTAssertEqual(cachedCounter2!.count, counter2.count)
    }
    
    func testFetchRemoteUserCountersWithNoLocalCounters() throws {
        
        // Setup
        
        let remoteCounter1 = UserCounterDecodable(id: "counter_1", count: 10)
        let remoteCounter2 = UserCounterDecodable(id: "counter_2", count: 20)
        
        assertLocalCounterIsNil(remoteCounter1.id)
        assertLocalCounterIsNil(remoteCounter2.id)

        userCountersApi.setMockFetchResponse(fetchedCounters: [remoteCounter1, remoteCounter2])
        
        // Perform
        
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
        
        // Assert
        
        XCTAssertNil(error)
        
        let counter1DataModel = syncedDataModels.first(where: { $0.id == remoteCounter1.id })
        let counter2DataModel = syncedDataModels.first(where: { $0.id == remoteCounter2.id })

        XCTAssertNotNil(counter1DataModel)
        XCTAssertNotNil(counter2DataModel)

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, remoteCounter1.count)
        XCTAssertEqual(counter1DataModel!.incrementValue, 0)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, remoteCounter2.count)
        XCTAssertEqual(counter2DataModel!.incrementValue, 0)
    }
    
    func testFetchRemoteUserCountersWithExistingLocalCounters() throws {
        
        // Setup
        
        let localCounter1 = UserCounterDomainModel(id: "counter_1", count: 2)
        let localCounter2 = UserCounterDomainModel(id: "counter_2", count: 4)
        
        cacheMockCounters([localCounter1, localCounter2])
        
        let remoteCounter1 = UserCounterDecodable(id: localCounter1.id, count: 5)
        let remoteCounter2 = UserCounterDecodable(id: localCounter2.id, count: 8)

        userCountersApi.setMockFetchResponse(fetchedCounters: [remoteCounter1, remoteCounter2])

        // Perform
        
        var error: Error?
        let expectation = expectation(description: "Fetch Existing Remote User Counters")
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
        
        // Assert
        
        XCTAssertNil(error)
        
        let counter1DataModel = syncedDataModels.first(where: { $0.id == localCounter1.id })
        let counter2DataModel = syncedDataModels.first(where: { $0.id == localCounter2.id })
        
        XCTAssertNotNil(counter1DataModel)
        XCTAssertNotNil(counter2DataModel)

        XCTAssertEqual(counter1DataModel!.latestCountFromAPI, remoteCounter1.count)
        XCTAssertEqual(counter1DataModel!.incrementValue, localCounter1.count)
        XCTAssertEqual(counter2DataModel!.latestCountFromAPI, remoteCounter2.count)
        XCTAssertEqual(counter2DataModel!.incrementValue, localCounter2.count)
        
        let counter1DomainModel = userCountersRepository.getUserCounter(id: localCounter1.id)
        let counter2DomainModel = userCountersRepository.getUserCounter(id: localCounter2.id)
        
        XCTAssertNotNil(counter1DomainModel)
        XCTAssertNotNil(counter2DomainModel)
        XCTAssertEqual(counter1DomainModel!.count, localCounter1.count + remoteCounter1.count)
        XCTAssertEqual(counter2DomainModel!.count, localCounter2.count + remoteCounter2.count)
    }
    
    func testSyncUpdatedUserCountersWithRemote() throws {
        
        // Setup
        
        // number of data changes expected: 2 to cache mock counters + 2 for sync
        let syncUpdateCompleteExpectation = makeExpectationForUserCounterChangesToOccur(numberOfChanges: 4)
        
        let localCounter1 = UserCounterDomainModel(id: "counter_1", count: 3)
        let localCounter2 = UserCounterDomainModel(id: "counter_2", count: 4)
        
        cacheMockCounters([localCounter1, localCounter2])
        
        let remoteCounter1 = UserCounterDecodable(id: localCounter1.id, count: 7)
        let remoteCounter2 = UserCounterDecodable(id: localCounter2.id, count: 12)
        
        userCountersApi.setMockRemoteCountResponse(countValues: [remoteCounter1.count, remoteCounter2.count])
        
        // Perform
        
        userCountersRepository.syncUpdatedUserCountersWithRemote()
        
        wait(for: [syncUpdateCompleteExpectation], timeout: 10)
        
        // Assert
        
        let updatedLocalCounter1 = userCountersRepository.getUserCounter(id: localCounter1.id)
        let updatedLocalCounter2 = userCountersRepository.getUserCounter(id: localCounter2.id)
        
        XCTAssertNotNil(updatedLocalCounter1)
        XCTAssertNotNil(updatedLocalCounter2)
        
        XCTAssertEqual(updatedLocalCounter1!.count, localCounter1.count + remoteCounter1.count)
        XCTAssertEqual(updatedLocalCounter2!.count, localCounter2.count + remoteCounter2.count)
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
        
        assertLocalCounterIsNil(counter.id)
        
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
    
    private func assertLocalCounterIsNil(_ id: String) {
        XCTAssertNil(userCountersRepository.getUserCounter(id: id))
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
