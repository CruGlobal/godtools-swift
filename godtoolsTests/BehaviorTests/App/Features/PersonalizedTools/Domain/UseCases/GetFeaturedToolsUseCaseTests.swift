//
//  GetFeaturedToolsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 9/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import SwiftData
import RepositorySync

private enum TestFeaturedToolsLanguageId {
    static let english: String = "0"
    static let french: String = "1"
}

private enum TestFeaturedToolsCountry {
    static let withFeaturedTools: String = "us"
    static let withoutFeaturedTools: String = "ca"
}

private enum TestFeaturedToolsId {
    static let featuredUnitedStatesEnglish: String = "featured_us_en"
}

struct GetFeaturedToolsUseCaseTests {

    struct ToolFixture {
        let id: String
        let resourceType: ResourceType
        let isHidden: Bool
        let languageCodes: [LanguageCodeDomainModel]
    }

    struct TestDependencies {
        let resourcesRepository: ResourcesRepository
        let languagesRepository: LanguagesRepository
        let personalizedToolsRepository: PersonalizedToolsRepository
        let favoritedResourcesRepository: FavoritedResourcesRepository
        let getTranslatedToolName: GetTranslatedToolName
        let getTranslatedToolCategory: GetTranslatedToolCategory
        let getToolListItemStrings: GetToolListItemStrings
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a country, which is represented as either no country or a country with an empty iso region code.
        When: Featured tools are requested.
        Then: I expect to see no featured tools rather than the request failing.
        """,
        arguments: [
            nil,
            LocalizationSettingsCountryDomainModel(isoRegionCode: "")
        ] as [LocalizationSettingsCountryDomainModel?]
    )
    @MainActor func noFeaturedToolsAreReturnedWhenNoCountryIsSelected(country: LocalizationSettingsCountryDomainModel?) async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: country
        )

        #expect(featuredTools.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country that has featured tools curated for their language.
        When: Featured tools are requested.
        Then: I expect to see the featured tools in the order the api returned them.
        """
    )
    @MainActor func featuredToolsAreReturnedInApiOrderForTheSelectedCountry() async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestFeaturedToolsCountry.withFeaturedTools)
        )

        #expect(featuredTools.map({ $0.dataModelId }) == ["tool-2", "tool-1"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country that has featured tools available in their app language.
        When: Featured tools are requested.
        Then: I expect each tool to report that it is available in my app language.
        """
    )
    @MainActor func featuredToolsReportLanguageAvailabilityInMyAppLanguage() async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestFeaturedToolsCountry.withFeaturedTools)
        )

        #expect(!featuredTools.isEmpty)

        for featuredTool in featuredTools {

            let languageAvailability: ToolLanguageAvailabilityDomainModel = try #require(featuredTool.languageAvailability)

            #expect(languageAvailability.isAvailable)
            #expect(!languageAvailability.availabilityString.isEmpty)
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: A featured tool is hidden.
        When: Featured tools are requested.
        Then: I expect the hidden tool to be excluded.
        """
    )
    @MainActor func hiddenToolsAreExcludedFromFeaturedTools() async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestFeaturedToolsCountry.withFeaturedTools)
        )

        #expect(!featuredTools.map({ $0.dataModelId }).contains("tool-hidden"))
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country that has no featured tools curated for their language.
        When: Featured tools are requested.
        Then: I expect to see no featured tools.
        """
    )
    @MainActor func noFeaturedToolsAreReturnedForACountryWithoutCuratedTools() async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestFeaturedToolsCountry.withoutFeaturedTools)
        )

        #expect(featuredTools.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country whose featured tools are curated for a different language than their app language.
        When: Featured tools are requested.
        Then: I expect to see no featured tools.
        """
    )
    @MainActor func noFeaturedToolsAreReturnedWhenTheyAreCuratedForADifferentLanguage() async throws {

        let featuredTools: [FeaturedToolListItemDomainModel] = try await getFeaturedTools(
            appLanguage: LanguageCodeDomainModel.french.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestFeaturedToolsCountry.withFeaturedTools)
        )

        #expect(featuredTools.isEmpty)
    }
}

// MARK: - Test Helpers

extension GetFeaturedToolsUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getFeaturedTools(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?) async throws -> [FeaturedToolListItemDomainModel] {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = GetFeaturedToolsUseCase(
            resourcesRepository: dependencies.resourcesRepository,
            personalizedToolsRepository: dependencies.personalizedToolsRepository,
            favoritedResourcesRepository: dependencies.favoritedResourcesRepository,
            languagesRepository: dependencies.languagesRepository,
            getTranslatedToolName: dependencies.getTranslatedToolName,
            getTranslatedToolCategory: dependencies.getTranslatedToolCategory,
            getToolListItemStrings: dependencies.getToolListItemStrings,
            getTranslatedToolLanguageAvailability: dependencies.getTranslatedToolLanguageAvailability
        )

        var cancellables: Set<AnyCancellable> = Set()

        var featuredToolsRef: [FeaturedToolListItemDomainModel]?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    country: country
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (featuredTools: [FeaturedToolListItemDomainModel]) in

                    guard featuredToolsRef == nil else {
                        return
                    }

                    featuredToolsRef = featuredTools

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(featuredToolsRef)
    }

    @available(iOS 17.4, *)
    private func getTestDependencies() throws -> TestDependencies {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let resourcesRepository: ResourcesRepository = testsDiContainer.core.dataLayer.getResourcesRepository()

        let cache = PersonalizedToolsCache(
            persistence: SwiftRepositorySyncPersistence(
                database: swiftDatabase,
                mapping: SwiftPersonalizedToolsMapping()
            )
        )

        let personalizedToolsRepository = PersonalizedToolsRepository(
            cache: cache,
            resourcesRepository: resourcesRepository,
            sync: PersonalizedToolsSync(
                api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
                cache: cache,
                syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
            )
        )

        return TestDependencies(
            resourcesRepository: resourcesRepository,
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            personalizedToolsRepository: personalizedToolsRepository,
            favoritedResourcesRepository: testsDiContainer.core.dataLayer.getFavoritedResourcesRepository(),
            getTranslatedToolName: testsDiContainer.core.domainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolCategory: testsDiContainer.core.domainLayer.supporting.getTranslatedToolCategory(),
            getToolListItemStrings: testsDiContainer.core.domainLayer.supporting.getToolListItemStrings(),
            getTranslatedToolLanguageAvailability: testsDiContainer.core.domainLayer.supporting.getTranslatedToolLanguageAvailability()
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .english: Self.createLanguage(id: TestFeaturedToolsLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestFeaturedToolsLanguageId.french, code: .french)
        ]

        let resources: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.resourceType = fixture.resourceType.rawValue
            resource.isHidden = fixture.isHidden

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

                resource.addLanguage(language: language)
            }

            return resource
        }

        let personalizedTools: [SwiftPersonalizedTools] = resourceIdsByPersonalizedToolsId.map { (personalizedToolsId: String, resourceIds: [String]) in

            let object = SwiftPersonalizedTools()
            object.id = personalizedToolsId
            object.resourceIds = resourceIds

            return object
        }

        return Array(languagesByCode.values) + resources + personalizedTools
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue
        language.name = code.rawValue + " Name"

        return language
    }

    private var resourceIdsByPersonalizedToolsId: [String: [String]] {

        return [
            TestFeaturedToolsId.featuredUnitedStatesEnglish: ["tool-2", "tool-hidden", "tool-1"]
        ]
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(id: "tool-1", resourceType: .tract, isHidden: false, languageCodes: [.english]),
            ToolFixture(id: "tool-2", resourceType: .tract, isHidden: false, languageCodes: [.english]),
            ToolFixture(id: "tool-hidden", resourceType: .tract, isHidden: true, languageCodes: [.english])
        ]
    }
}
