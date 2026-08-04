//
//  GetLocalizationSettingsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import RepositorySync

struct GetLocalizationSettingsUseCaseTests {

    struct ObservedLocalizationSettings {
        let userLocalizationSettings: UserLocalizationSettingsDomainModel?
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I have not selected a country in my localization settings.
        When: My localization settings are observed.
        Then: I expect to not have any localization settings.
        """
    )
    @MainActor func noLocalizationSettingsExistWhenIHaveNotSelectedACountry() async throws {

        let repository: UserLocalizationSettingsRepository = try getUserLocalizationSettingsRepository()

        let observed: ObservedLocalizationSettings = try await observeFirstLocalizationSettings(repository: repository)

        #expect(observed.userLocalizationSettings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I have selected a country in my localization settings.
        When: My localization settings are observed.
        Then: I expect my selected country to be the country I selected.
        """,
        arguments: ["US", "ES", "JP"]
    )
    @MainActor func mySelectedCountryIsReturned(isoRegionCode: String) async throws {

        let repository: UserLocalizationSettingsRepository = try getUserLocalizationSettingsRepository()

        try await repository.storeUserCountry(isoRegionCode: isoRegionCode)

        let observed: ObservedLocalizationSettings = try await observeFirstLocalizationSettings(repository: repository)

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try #require(observed.userLocalizationSettings)

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode == isoRegionCode)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I have selected a country in my localization settings.
        When: My localization settings are observed.
        Then: I expect my selected country to not have any translated country names since only the country's iso region code is stored.
        """
    )
    @MainActor func mySelectedCountryDoesNotIncludeTranslatedCountryNames() async throws {

        let repository: UserLocalizationSettingsRepository = try getUserLocalizationSettingsRepository()

        try await repository.storeUserCountry(isoRegionCode: "US")

        let observed: ObservedLocalizationSettings = try await observeFirstLocalizationSettings(repository: repository)

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try #require(observed.userLocalizationSettings)

        #expect(userLocalizationSettings.selectedCountry.countryNameTranslatedInOwnLanguage.isEmpty)
        #expect(userLocalizationSettings.selectedCountry.countryNameTranslatedInCurrentAppLanguage.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I selected prefer not to say in my localization settings.
        When: My localization settings are observed.
        Then: I expect to have localization settings with a selected country that does not have an iso region code.
        """
    )
    @MainActor func preferNotToSayIsReturnedAsASelectedCountryWithoutAnIsoRegionCode() async throws {

        let repository: UserLocalizationSettingsRepository = try getUserLocalizationSettingsRepository()

        try await repository.storeUserCountry(isoRegionCode: "")

        let observed: ObservedLocalizationSettings = try await observeFirstLocalizationSettings(repository: repository)

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try #require(observed.userLocalizationSettings)

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I am observing my localization settings and have selected a country.
        When: I select a different country.
        Then: I expect my localization settings to update to my newly selected country.
        """
    )
    @MainActor func myLocalizationSettingsUpdateWhenISelectADifferentCountry() async throws {

        let repository: UserLocalizationSettingsRepository = try getUserLocalizationSettingsRepository()

        try await repository.storeUserCountry(isoRegionCode: "US")

        let observed: ObservedLocalizationSettings = try await observeLocalizationSettings(
            repository: repository,
            whileObserving: {
                try await repository.storeUserCountry(isoRegionCode: "JP")
            },
            untilObserved: { (userLocalizationSettings: UserLocalizationSettingsDomainModel?) in
                return userLocalizationSettings?.selectedCountry.isoRegionCode == "JP"
            }
        )

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try #require(observed.userLocalizationSettings)

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode == "JP")
    }
}

// MARK: - Test Helpers

extension GetLocalizationSettingsUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func observeFirstLocalizationSettings(repository: UserLocalizationSettingsRepository) async throws -> ObservedLocalizationSettings {

        return try await observeLocalizationSettings(
            repository: repository,
            untilObserved: { _ in
                return true
            }
        )
    }

    @available(iOS 17.4, *)
    @MainActor private func observeLocalizationSettings(
        repository: UserLocalizationSettingsRepository,
        whileObserving: (@MainActor () async throws -> Void)? = nil,
        untilObserved: @escaping (UserLocalizationSettingsDomainModel?) -> Bool
    ) async throws -> ObservedLocalizationSettings {

        let useCase = GetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: repository
        )

        var cancellables: Set<AnyCancellable> = Set()

        var observedRef: ObservedLocalizationSettings?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute()
                .receive(on: DispatchQueue.main)
                .sink { (userLocalizationSettings: UserLocalizationSettingsDomainModel?) in

                    guard observedRef == nil, untilObserved(userLocalizationSettings) else {
                        return
                    }

                    observedRef = ObservedLocalizationSettings(userLocalizationSettings: userLocalizationSettings)

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)

            if let whileObserving = whileObserving {

                Task { @MainActor in
                    try await whileObserving()
                }
            }
        }

        return try #require(observedRef)
    }

    @available(iOS 17.4, *)
    private func getUserLocalizationSettingsRepository() throws -> UserLocalizationSettingsRepository {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let persistence = SwiftRepositorySyncPersistence(
            database: swiftDatabase,
            mapping: SwiftUserLocalizationSettingsMapping()
        )

        return UserLocalizationSettingsRepository(
            cache: UserLocalizationSettingsCache(persistence: persistence)
        )
    }
}
