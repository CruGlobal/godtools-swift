//
//  GetToolShortcutLinksUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import SwiftData
import RepositorySync

private enum TestToolId {
    static let kgp: String = "tool-kgp"
    static let fourLaws: String = "tool-fourlaws"
    static let satisfied: String = "tool-satisfied"
    static let teachMeToShare: String = "tool-teachmetoshare"
    static let honorRestored: String = "tool-honorrestored"
    static let notDownloaded: String = "tool-not-in-resources"
}

private enum TestLanguageId {
    static let english: String = "0"
    static let spanish: String = "1"
}

struct GetToolShortcutLinksUseCaseTests {

    struct ToolFixture {
        let id: String
        let abbreviation: String
        let name: String
        let translatedNamesByLanguageId: [String: String]
    }

    struct FavoritesArgument {
        let favoritedToolIdsByPosition: [String: Int]
        let expectedDeepLinkUrls: [String]
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedTitles: [String]
        let expectedDeepLinkUrls: [String]
    }

    private let allFavoritedToolIdsByPosition: [String: Int] = [
        TestToolId.kgp: 0,
        TestToolId.fourLaws: 1,
        TestToolId.satisfied: 2,
        TestToolId.teachMeToShare: 3,
        TestToolId.honorRestored: 4
    ]

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited tools.
        When: The tool shortcut links are requested.
        Then: I expect a deep link url pointing at the tool on the first page.
        """
    )
    @MainActor func deepLinkUrlPointsAtTheToolOnTheFirstPage() async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.english.value,
            favoritedToolIdsByPosition: [TestToolId.kgp: 0]
        )

        let shortcutLink: ToolShortcutLinkDomainModel = try #require(shortcutLinks.first)

        #expect(shortcutLink.appDeepLinkUrl == "godtools://knowgod.com/en/kgp/0")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited tools.
        When: The tool shortcut links are requested.
        Then: I expect the deep link url to use the godtools app scheme and knowgod.com host.
        """
    )
    @MainActor func deepLinkUrlUsesTheGodToolsAppSchemeAndKnowGodHost() async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.english.value,
            favoritedToolIdsByPosition: allFavoritedToolIdsByPosition
        )

        #expect(shortcutLinks.isEmpty == false)

        for shortcutLink in shortcutLinks {

            let urlComponents: URLComponents = try #require(URLComponents(string: shortcutLink.appDeepLinkUrl))

            #expect(urlComponents.scheme == "godtools")
            #expect(urlComponents.host == "knowgod.com")
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited more tools than can be shown as shortcuts.
        When: The tool shortcut links are requested.
        Then: I expect at most four shortcut links, ordered by the favorited tool position.
        """,
        arguments: [
            FavoritesArgument(
                favoritedToolIdsByPosition: [:],
                expectedDeepLinkUrls: []
            ),
            FavoritesArgument(
                favoritedToolIdsByPosition: [TestToolId.satisfied: 0],
                expectedDeepLinkUrls: [
                    "godtools://knowgod.com/en/satisfied/0"
                ]
            ),
            FavoritesArgument(
                favoritedToolIdsByPosition: [TestToolId.fourLaws: 1, TestToolId.kgp: 0],
                expectedDeepLinkUrls: [
                    "godtools://knowgod.com/en/kgp/0",
                    "godtools://knowgod.com/en/fourlaws/0"
                ]
            ),
            FavoritesArgument(
                favoritedToolIdsByPosition: [
                    TestToolId.kgp: 0,
                    TestToolId.fourLaws: 1,
                    TestToolId.satisfied: 2,
                    TestToolId.teachMeToShare: 3,
                    TestToolId.honorRestored: 4
                ],
                expectedDeepLinkUrls: [
                    "godtools://knowgod.com/en/kgp/0",
                    "godtools://knowgod.com/en/fourlaws/0",
                    "godtools://knowgod.com/en/satisfied/0",
                    "godtools://knowgod.com/en/teachmetoshare/0"
                ]
            )
        ]
    )
    @MainActor func atMostFourShortcutLinksAreReturnedOrderedByFavoritedPosition(argument: FavoritesArgument) async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.english.value,
            favoritedToolIdsByPosition: argument.favoritedToolIdsByPosition
        )

        #expect(shortcutLinks.map({ $0.appDeepLinkUrl }) == argument.expectedDeepLinkUrls)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited tools.
        When: My app language is set.
        Then: I expect the shortcut link titles and deep link urls to be in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedTitles: ["Knowing God Personally", "Four Spiritual Laws"],
                expectedDeepLinkUrls: [
                    "godtools://knowgod.com/en/kgp/0",
                    "godtools://knowgod.com/en/fourlaws/0"
                ]
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedTitles: ["Conocer a Dios Personalmente", "Cuatro Leyes Espirituales"],
                expectedDeepLinkUrls: [
                    "godtools://knowgod.com/es/kgp/0",
                    "godtools://knowgod.com/es/fourlaws/0"
                ]
            )
        ]
    )
    @MainActor func shortcutLinksAreInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: argument.appLanguage,
            favoritedToolIdsByPosition: [TestToolId.kgp: 0, TestToolId.fourLaws: 1]
        )

        #expect(shortcutLinks.map({ $0.title }) == argument.expectedTitles)
        #expect(shortcutLinks.map({ $0.appDeepLinkUrl }) == argument.expectedDeepLinkUrls)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited a tool that is not translated in my app language.
        When: The tool shortcut links are requested.
        Then: I expect the title to fall back to the english translated name.
        """
    )
    @MainActor func titleFallsBackToTheEnglishTranslatedNameWhenNotTranslatedInMyAppLanguage() async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.spanish.value,
            favoritedToolIdsByPosition: [TestToolId.satisfied: 0]
        )

        let shortcutLink: ToolShortcutLinkDomainModel = try #require(shortcutLinks.first)

        #expect(shortcutLink.title == "Satisfied?")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited a tool that has no translations.
        When: The tool shortcut links are requested.
        Then: I expect the title to fall back to the resource name.
        """
    )
    @MainActor func titleFallsBackToTheResourceNameWhenThereAreNoTranslations() async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.english.value,
            favoritedToolIdsByPosition: [TestToolId.honorRestored: 0]
        )

        let shortcutLink: ToolShortcutLinkDomainModel = try #require(shortcutLinks.first)

        #expect(shortcutLink.title == "Honor Restored Resource Name")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has favorited a tool that no longer exists in their downloaded resources.
        When: The tool shortcut links are requested.
        Then: I expect that tool to be excluded from the shortcut links.
        """
    )
    @MainActor func favoritedToolsMissingFromResourcesAreExcluded() async throws {

        let shortcutLinks: [ToolShortcutLinkDomainModel] = try await getToolShortcutLinks(
            appLanguage: LanguageCodeDomainModel.english.value,
            favoritedToolIdsByPosition: [TestToolId.notDownloaded: 0, TestToolId.kgp: 1]
        )

        #expect(shortcutLinks.map({ $0.appDeepLinkUrl }) == ["godtools://knowgod.com/en/kgp/0"])
    }
}

// MARK: - Test Helpers

extension GetToolShortcutLinksUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getToolShortcutLinks(appLanguage: AppLanguageDomainModel, favoritedToolIdsByPosition: [String: Int]) async throws -> [ToolShortcutLinkDomainModel] {

        let useCase: GetToolShortcutLinksUseCase = try await getUseCase(favoritedToolIdsByPosition: favoritedToolIdsByPosition)

        var cancellables: Set<AnyCancellable> = Set()

        var shortcutLinksRef: [ToolShortcutLinkDomainModel]?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (shortcutLinks: [ToolShortcutLinkDomainModel]) in

                    guard shortcutLinksRef == nil else {
                        return
                    }

                    shortcutLinksRef = shortcutLinks

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(shortcutLinksRef)
    }

    @available(iOS 17.4, *)
    private func getUseCase(favoritedToolIdsByPosition: [String: Int]) async throws -> GetToolShortcutLinksUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        try await testsDiContainer.core.dataLayer.getFavoritedResourcesPersistence()
            .writeObjects(externalObjects: getFavoritedResources(favoritedToolIdsByPosition: favoritedToolIdsByPosition))

        return testsDiContainer.feature.toolShortcutLinks.domainLayer.getToolShortcutLinksUseCase()
    }

    private func getFavoritedResources(favoritedToolIdsByPosition: [String: Int]) -> [FavoritedResourceDataModel] {

        return favoritedToolIdsByPosition.map { (toolId: String, position: Int) in

            FavoritedResourceDataModel(
                id: toolId,
                createdAt: Date(),
                position: position
            )
        }
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesById: [String: SwiftLanguage] = [
            TestLanguageId.english: Self.createLanguage(id: TestLanguageId.english, code: .english),
            TestLanguageId.spanish: Self.createLanguage(id: TestLanguageId.spanish, code: .spanish)
        ]

        var translations: [SwiftTranslation] = Array()

        let resources: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.abbreviation = fixture.abbreviation
            resource.name = fixture.name
            resource.resourceType = ResourceType.tract.rawValue

            for (languageId, translatedName) in fixture.translatedNamesByLanguageId {

                guard let language = languagesById[languageId] else {
                    continue
                }

                let translation = SwiftTranslation()
                translation.id = fixture.id + "-" + languageId
                translation.translatedName = translatedName
                translation.version = 1
                translation.isPublished = true
                translation.language = language
                translation.resource = resource

                resource.addLatestTranslation(translation: translation)

                translations.append(translation)
            }

            return resource
        }

        return Array(languagesById.values) + resources + translations
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue
        language.name = code.rawValue + " Name"

        return language
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(
                id: TestToolId.kgp,
                abbreviation: "kgp",
                name: "Knowing God Personally Resource Name",
                translatedNamesByLanguageId: [
                    TestLanguageId.english: "Knowing God Personally",
                    TestLanguageId.spanish: "Conocer a Dios Personalmente"
                ]
            ),
            ToolFixture(
                id: TestToolId.fourLaws,
                abbreviation: "fourlaws",
                name: "Four Spiritual Laws Resource Name",
                translatedNamesByLanguageId: [
                    TestLanguageId.english: "Four Spiritual Laws",
                    TestLanguageId.spanish: "Cuatro Leyes Espirituales"
                ]
            ),
            ToolFixture(
                id: TestToolId.satisfied,
                abbreviation: "satisfied",
                name: "Satisfied Resource Name",
                translatedNamesByLanguageId: [
                    TestLanguageId.english: "Satisfied?"
                ]
            ),
            ToolFixture(
                id: TestToolId.teachMeToShare,
                abbreviation: "teachmetoshare",
                name: "Teach Me To Share Resource Name",
                translatedNamesByLanguageId: [
                    TestLanguageId.english: "Teach Me To Share"
                ]
            ),
            ToolFixture(
                id: TestToolId.honorRestored,
                abbreviation: "honorrestored",
                name: "Honor Restored Resource Name",
                translatedNamesByLanguageId: [:]
            )
        ]
    }
}
