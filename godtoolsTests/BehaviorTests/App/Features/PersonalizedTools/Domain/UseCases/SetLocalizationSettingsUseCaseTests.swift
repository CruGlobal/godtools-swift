//
//  SetLocalizationSettingsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync

struct SetLocalizationSettingsUseCaseTests {

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I am viewing my localization settings.
        When: I select a country.
        Then: I expect my localization settings to have the country I selected.
        """,
        arguments: ["US", "ES", "JP"]
    )
    func myLocalizationSettingsHaveTheCountryISelected(isoRegionCode: String) async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dependencies.repository
        )

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try await useCase
            .execute(
                country: LocalizationSettingsCountryDomainModel(isoRegionCode: isoRegionCode)
            )

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode == isoRegionCode)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I am viewing my localization settings.
        When: I select a country.
        Then: I expect my selected country to be persisted so it is available the next time I launch the app.
        """,
        arguments: ["US", "ES", "JP"]
    )
    func mySelectedCountryIsPersisted(isoRegionCode: String) async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dependencies.repository
        )

        _ = try await useCase
            .execute(
                country: LocalizationSettingsCountryDomainModel(isoRegionCode: isoRegionCode)
            )

        let dataModel: UserLocalizationSettingsDataModel = try #require(dependencies.repository.getUserLocalizationSetting())

        #expect(dataModel.selectedCountryIsoRegionCode == isoRegionCode)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I am viewing my localization settings.
        When: I select a country with translated country names.
        Then: I expect my localization settings to keep the translated country names of the country I selected.
        """
    )
    func myLocalizationSettingsKeepTheTranslatedCountryNamesOfTheCountryISelected() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dependencies.repository
        )

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try await useCase
            .execute(
                country: LocalizationSettingsCountryDomainModel(
                    isoRegionCode: "ES",
                    countryNameTranslatedInOwnLanguage: "España",
                    countryNameTranslatedInCurrentAppLanguage: "Spain"
                )
            )

        #expect(userLocalizationSettings.selectedCountry.countryNameTranslatedInOwnLanguage == "España")
        #expect(userLocalizationSettings.selectedCountry.countryNameTranslatedInCurrentAppLanguage == "Spain")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I am viewing my localization settings.
        When: I select prefer not to say.
        Then: I expect my localization settings to have a selected country without an iso region code.
        """
    )
    func selectingPreferNotToSayStoresACountryWithoutAnIsoRegionCode() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dependencies.repository
        )

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try await useCase
            .execute(
                country: LocalizationSettingsCountryListItem
                    .preferNotToSay(
                        LocalizationSettingsPreferNotToSayDomainModel(preferNotToSayText: "Prefer not to say")
                    )
                    .countryDomainModel
            )

        let dataModel: UserLocalizationSettingsDataModel = try #require(dependencies.repository.getUserLocalizationSetting())

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode.isEmpty)
        #expect(dataModel.selectedCountryIsoRegionCode.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I have already selected a country in my localization settings.
        When: I select a different country.
        Then: I expect my newly selected country to replace my previously selected country.
        """
    )
    func selectingADifferentCountryReplacesMyPreviouslySelectedCountry() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dependencies.repository
        )

        _ = try await useCase
            .execute(
                country: LocalizationSettingsCountryDomainModel(isoRegionCode: "US")
            )

        let userLocalizationSettings: UserLocalizationSettingsDomainModel = try await useCase
            .execute(
                country: LocalizationSettingsCountryDomainModel(isoRegionCode: "JP")
            )

        let dataModel: UserLocalizationSettingsDataModel = try #require(dependencies.repository.getUserLocalizationSetting())

        #expect(userLocalizationSettings.selectedCountry.isoRegionCode == "JP")
        #expect(dataModel.selectedCountryIsoRegionCode == "JP")
        #expect(try dependencies.persistence.getObjectCount() == 1)
    }
}

// MARK: - Test Helpers

extension SetLocalizationSettingsUseCaseTests {

    @available(iOS 17.4, *)
    struct TestDependencies {
        let persistence: SwiftRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, SwiftUserLocalizationSettings>
        let repository: UserLocalizationSettingsRepository
    }

    @available(iOS 17.4, *)
    private func getTestDependencies() throws -> TestDependencies {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let persistence = SwiftRepositorySyncPersistence(
            database: swiftDatabase,
            mapping: SwiftUserLocalizationSettingsMapping()
        )

        return TestDependencies(
            persistence: persistence,
            repository: UserLocalizationSettingsRepository(
                cache: UserLocalizationSettingsCache(persistence: persistence)
            )
        )
    }
}
