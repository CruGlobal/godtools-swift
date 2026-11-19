//
//  UserToolFilterSettingsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine

private enum TestValue {
    static let english: String = "0"
    static let french: String = "1"
    static let spanish: String = "2"
}

private enum TestUserId {
    static let authenticated: String = "authenticated_user_id"
}

struct UserToolFilterSettingsRepositoryTests {
    
    private static let firstValueTimeoutNanoseconds: UInt64 = 30_000_000_000
    private static let settingDidNotChangeTimeoutNanoseconds: UInt64 = 3_000_000_000
    
    struct SettingTypeArgument {
        let settingType: UserToolFilterSettingType
    }
    
    @Test(
        """
        Given: User has not selected a value for a tool filter setting.
        When: The setting value is requested.
        Then: I expect to not receive a value.
        """,
        arguments: UserToolFilterSettingType.allCases.map { SettingTypeArgument(settingType: $0) }
    )
    @MainActor func settingValueIsNotFoundWhenTheUserHasNotStoredAValue(argument: SettingTypeArgument) async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        let value: String? = await repository.getSettingValue(settingType: argument.settingType)
        
        #expect(value == nil)
    }
    
    @Test(
        """
        Given: User is selecting a value for a tool filter setting.
        When: The value is stored.
        Then: I expect the stored value to be returned when the setting is requested.
        """,
        arguments: UserToolFilterSettingType.allCases.map { SettingTypeArgument(settingType: $0) }
    )
    @MainActor func storedSettingValueIsReturnedWhenTheSettingIsRequested(argument: SettingTypeArgument) async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: argument.settingType, value: TestValue.french)
        
        let value: String? = await repository.getSettingValue(settingType: argument.settingType)
        
        #expect(value == TestValue.french)
    }
    
    @Test(
        """
        Given: User has stored a value for a tool filter setting.
        When: A new value is stored for that setting.
        Then: I expect the new value to replace the previous value.
        """
    )
    @MainActor func storingANewSettingValueReplacesThePreviousValue() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.spanish)
        
        let value: String? = await repository.getSettingValue(settingType: .toolsLanguageFilter)
        let settings: [UserToolFilterSettingsDataModel] = await repository.getSettings()
        
        #expect(value == TestValue.spanish)
        #expect(settings.count == 1)
    }
    
    @Test(
        """
        Given: User has stored a value for a tool filter setting.
        When: An empty value is stored for that setting.
        Then: I expect the setting to be removed.
        """
    )
    @MainActor func storingAnEmptySettingValueRemovesTheSetting() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsCategoryFilter, value: TestValue.english)
        try await repository.storeSettingValue(settingType: .toolsCategoryFilter, value: nil)
        
        let value: String? = await repository.getSettingValue(settingType: .toolsCategoryFilter)
        let settings: [UserToolFilterSettingsDataModel] = await repository.getSettings()
        
        #expect(value == nil)
        #expect(settings.isEmpty)
    }
    
    @Test(
        """
        Given: User has stored a value for a tool filter setting.
        When: The setting is deleted.
        Then: I expect the setting to be removed.
        """
    )
    @MainActor func deletingASettingRemovesTheSetting() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .lessonsLanguageFilter, value: TestValue.english)
        try await repository.deleteSetting(settingType: .lessonsLanguageFilter)
        
        let value: String? = await repository.getSettingValue(settingType: .lessonsLanguageFilter)
        
        #expect(value == nil)
    }
    
    @Test(
        """
        Given: User is selecting values for several tool filter settings.
        When: Each setting value is stored.
        Then: I expect every setting to keep its own value.
        """
    )
    @MainActor func eachSettingTypeKeepsItsOwnValue() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .lessonsLanguageFilter, value: TestValue.english)
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
        try await repository.storeSettingValue(settingType: .toolsCategoryFilter, value: TestValue.spanish)
        
        let lessonsLanguageId: String? = await repository.getSettingValue(settingType: .lessonsLanguageFilter)
        let toolsLanguageId: String? = await repository.getSettingValue(settingType: .toolsLanguageFilter)
        let toolsCategoryId: String? = await repository.getSettingValue(settingType: .toolsCategoryFilter)
        let personalizedToolsLanguageId: String? = await repository.getSettingValue(settingType: .personalizedToolsLanguageFilter)
        let settings: [UserToolFilterSettingsDataModel] = await repository.getSettings()
        
        #expect(lessonsLanguageId == TestValue.english)
        #expect(toolsLanguageId == TestValue.french)
        #expect(toolsCategoryId == TestValue.spanish)
        #expect(personalizedToolsLanguageId == nil)
        #expect(settings.count == 3)
    }
    
    @Test(
        """
        Given: A tool filter setting is stored for an authenticated user.
        When: The same setting is requested for a different user.
        Then: I expect each user to keep their own value.
        """
    )
    @MainActor func settingValuesAreScopedToTheUserTheyWereStoredFor() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(
            settingType: .toolsLanguageFilter,
            value: TestValue.french,
            userId: TestUserId.authenticated
        )
        
        let authenticatedUserValue: String? = await repository.getSettingValue(
            settingType: .toolsLanguageFilter,
            userId: TestUserId.authenticated
        )
        
        let sharedUserValue: String? = await repository.getSettingValue(settingType: .toolsLanguageFilter)
        
        #expect(authenticatedUserValue == TestValue.french)
        #expect(sharedUserValue == nil)
    }
    @Test(
        """
        Given: User is selecting a value for a tool filter setting.
        When: The value is stored.
        Then: I expect the setting to be keyed by the user id and setting type.
        """
    )
    @MainActor func storedSettingIsKeyedByUserIdAndSettingType() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(
            settingType: .toolsLanguageFilter,
            value: TestValue.french,
            userId: TestUserId.authenticated
        )
        
        let setting: UserToolFilterSettingsDataModel = try #require(
            await repository.getSetting(settingType: .toolsLanguageFilter, userId: TestUserId.authenticated)
        )
        
        #expect(setting.id == "\(TestUserId.authenticated).toolsLanguageFilter")
        #expect(setting.userId == TestUserId.authenticated)
        #expect(setting.settingType == UserToolFilterSettingType.toolsLanguageFilter.rawValue)
        #expect(setting.value == TestValue.french)
    }
    
    @Test(
        """
        Given: Tool filter settings are stored for an authenticated user.
        When: That user's settings are requested.
        Then: I expect to receive only that user's settings.
        """
    )
    @MainActor func requestingSettingsForAUserReturnsOnlyThatUsersSettings() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.english)
        
        try await repository.storeSettingValue(
            settingType: .toolsLanguageFilter,
            value: TestValue.french,
            userId: TestUserId.authenticated
        )
        
        try await repository.storeSettingValue(
            settingType: .lessonsLanguageFilter,
            value: TestValue.spanish,
            userId: TestUserId.authenticated
        )
        
        let authenticatedUserSettings: [UserToolFilterSettingsDataModel] = await repository.getSettings(
            userId: TestUserId.authenticated
        )
        
        let sharedUserSettings: [UserToolFilterSettingsDataModel] = await repository.getSettings()
        
        #expect(authenticatedUserSettings.count == 2)
        #expect(sharedUserSettings.count == 1)
        #expect(authenticatedUserSettings.allSatisfy { $0.userId == TestUserId.authenticated })
    }
    
    @Test(
        """
        Given: A tool filter setting is stored for an authenticated user and for the shared user.
        When: The authenticated user's setting is deleted.
        Then: I expect the shared user's setting to be left in place.
        """
    )
    @MainActor func deletingASettingForAUserLeavesOtherUsersSettingsInPlace() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.english)
        
        try await repository.storeSettingValue(
            settingType: .toolsLanguageFilter,
            value: TestValue.french,
            userId: TestUserId.authenticated
        )
        
        try await repository.deleteSetting(settingType: .toolsLanguageFilter, userId: TestUserId.authenticated)
        
        let authenticatedUserValue: String? = await repository.getSettingValue(
            settingType: .toolsLanguageFilter,
            userId: TestUserId.authenticated
        )
        
        let sharedUserValue: String? = await repository.getSettingValue(settingType: .toolsLanguageFilter)
        
        #expect(authenticatedUserValue == nil)
        #expect(sharedUserValue == TestValue.english)
    }
}

// MARK: - Persistence Failures

extension UserToolFilterSettingsRepositoryTests {
    
    @Test(
        """
        Given: The database is unavailable.
        When: A tool filter setting is requested.
        Then: I expect to not receive a value rather than an error.
        """
    )
    @MainActor func requestingASettingWhenTheDatabaseIsUnavailableReturnsNoValue() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepositoryWithFailingPersistence()
        
        let setting: UserToolFilterSettingsDataModel? = await repository.getSetting(settingType: .toolsLanguageFilter)
        let value: String? = await repository.getSettingValue(settingType: .toolsLanguageFilter)
        let settings: [UserToolFilterSettingsDataModel] = await repository.getSettings()
        
        #expect(setting == nil)
        #expect(value == nil)
        #expect(settings.isEmpty)
    }
    
    @Test(
        """
        Given: The database is unavailable.
        When: A tool filter setting value is stored.
        Then: I expect an error to be thrown.
        """
    )
    @MainActor func storingASettingWhenTheDatabaseIsUnavailableThrows() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepositoryWithFailingPersistence()
        
        await #expect(throws: FakeFailingPersistenceError.self) {
            try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
        }
    }
    
    @Test(
        """
        Given: The database is unavailable.
        When: A tool filter setting is observed.
        Then: I expect the observer to fail with the persistence error rather than hang.
        """
    )
    @MainActor func observingASettingWhenTheDatabaseIsUnavailableFailsWithTheError() async throws {

        let repository: UserToolFilterSettingsRepository = getRepositoryWithFailingPersistence()

        await #expect(throws: FakeFailingPersistenceError.self) {
            for try await _ in repository.observeSettingValueChangedPublisher(settingType: .toolsLanguageFilter).values {

            }
        }
    }
}

// MARK: - Observing

extension UserToolFilterSettingsRepositoryTests {
    
    @Test(
        """
        Given: User has stored a value for a tool filter setting.
        When: The setting is observed.
        Then: I expect to receive the stored value on the first observation.
        """
    )
    @MainActor func observingASettingEmitsTheStoredValueOnFirstObservation() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
        
        let values: [String?] = await observeSettingValues(
            repository: repository,
            settingType: .toolsLanguageFilter,
            expectedValueCount: 1,
            whileObserving: nil
        )
        
        #expect(values == [TestValue.french])
    }
    
    @Test(
        """
        Given: User is observing a tool filter setting.
        When: A new value is stored for that setting.
        Then: I expect to receive the new value.
        """
    )
    @MainActor func observingASettingEmitsWhenTheSettingValueChanges() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        let values: [String?] = await observeSettingValues(
            repository: repository,
            settingType: .toolsLanguageFilter,
            expectedValueCount: 2,
            whileObserving: {
                try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.spanish)
            }
        )
        
        #expect(values == [nil, TestValue.spanish])
    }
    
    @Test(
        """
        Given: User is observing a tool filter setting.
        When: A different tool filter setting is changed.
        Then: I expect to not receive another value for the observed setting.
        """
    )
    @MainActor func observingASettingDoesNotEmitWhenADifferentSettingChanges() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        let values: [String?] = await observeSettingValues(
            repository: repository,
            settingType: .toolsLanguageFilter,
            expectedValueCount: 2,
            afterFirstValueTimeoutNanoseconds: Self.settingDidNotChangeTimeoutNanoseconds,
            whileObserving: {
                try await repository.storeSettingValue(settingType: .lessonsLanguageFilter, value: TestValue.spanish)
            }
        )
        
        #expect(values == [nil])
    }
    
    @Test(
        """
        Given: User is observing a tool filter setting.
        When: The value already stored for that setting is stored again.
        Then: I expect to not receive another value for the observed setting.
        """
    )
    @MainActor func observingASettingDoesNotEmitWhenAnUnchangedValueIsStored() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
        
        let values: [String?] = await observeSettingValues(
            repository: repository,
            settingType: .toolsLanguageFilter,
            expectedValueCount: 2,
            afterFirstValueTimeoutNanoseconds: Self.settingDidNotChangeTimeoutNanoseconds,
            whileObserving: {
                try await repository.storeSettingValue(settingType: .toolsLanguageFilter, value: TestValue.french)
            }
        )
        
        #expect(values == [TestValue.french])
    }
    
    @Test(
        """
        Given: User is observing a tool filter setting that has a stored value.
        When: The setting is deleted.
        Then: I expect to receive an empty value.
        """
    )
    @MainActor func observingASettingEmitsAnEmptyValueWhenTheSettingIsDeleted() async throws {
        
        let repository: UserToolFilterSettingsRepository = getRepository()
        
        try await repository.storeSettingValue(settingType: .toolsCategoryFilter, value: TestValue.english)
        
        let values: [String?] = await observeSettingValues(
            repository: repository,
            settingType: .toolsCategoryFilter,
            expectedValueCount: 2,
            whileObserving: {
                try await repository.storeSettingValue(settingType: .toolsCategoryFilter, value: nil)
            }
        )
        
        #expect(values == [TestValue.english, nil])
    }
}

// MARK: - Test Helpers

extension UserToolFilterSettingsRepositoryTests {
    
    private func getRepository() -> UserToolFilterSettingsRepository {
        
        let testsDiContainer = TestsDiContainer(testsAppConfig: TestsAppConfig())
        
        return testsDiContainer.core.dataLayer.getUserToolFilterSettingsRepository()
    }
    
    private func getRepositoryWithFailingPersistence() -> UserToolFilterSettingsRepository {
        
        return UserToolFilterSettingsRepository(
            cache: UserToolFilterSettingsCache(
                persistence: FakeFailingPersistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel>()
            )
        )
    }
    
    @MainActor private func observeSettingValues(repository: UserToolFilterSettingsRepository, settingType: UserToolFilterSettingType, expectedValueCount: Int, afterFirstValueTimeoutNanoseconds: UInt64? = nil, whileObserving: (() async throws -> Void)?) async -> [String?] {
        
        var cancellables: Set<AnyCancellable> = Set()
        var timeoutCancellable: AnyCancellable?
        var values: [String?] = Array()
        var didResume: Bool = false
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            
            func resume() {
                
                guard !didResume else {
                    return
                }
                
                didResume = true
                timeoutCancellable?.cancel()
                continuation.resume(returning: ())
            }
            
            func startTimeout(nanoseconds: UInt64) {
                
                timeoutCancellable?.cancel()
                
                timeoutCancellable = Just(())
                    .delay(for: .nanoseconds(Int(nanoseconds)), scheduler: DispatchQueue.main)
                    .sink { _ in
                        resume()
                    }
            }
            
            startTimeout(nanoseconds: Self.firstValueTimeoutNanoseconds)
            
            repository
                .observeSettingValueChangedPublisher(settingType: settingType)
                .receive(on: DispatchQueue.main)
                .sink { _ in

                } receiveValue: { (value: String?) in

                    guard !didResume else {
                        return
                    }
                    
                    values.append(value)
                    
                    if values.count == 1 {
                        
                        if let afterFirstValueTimeoutNanoseconds = afterFirstValueTimeoutNanoseconds {
                            startTimeout(nanoseconds: afterFirstValueTimeoutNanoseconds)
                        }
                        
                        if let whileObserving = whileObserving {
                            Task {
                                try await whileObserving()
                            }
                        }
                    }
                    
                    guard values.count >= expectedValueCount else {
                        return
                    }
                    
                    resume()
                }
                .store(in: &cancellables)
        }
        
        return values
    }
}
