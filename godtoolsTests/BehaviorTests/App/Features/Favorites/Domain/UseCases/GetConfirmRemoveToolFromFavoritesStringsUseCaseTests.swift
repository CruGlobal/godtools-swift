//
//  GetConfirmRemoveToolFromFavoritesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData
import RepositorySync

struct GetConfirmRemoveToolFromFavoritesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedMessage: String
    }

    private static let toolId: String = "1"
    private static let toolNameInEnglish: String = "Tool Name EN"
    private static let toolNameInSpanish: String = "Tool Name ES"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is confirming the removal of a tool from their favorites.
        When: The confirm remove tool from favorites strings are requested for an app language.
        Then: Each string is localized for the app language and the message contains the translated tool name.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value, expectedMessage: "Remove \(toolNameInEnglish) from favorites?"),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value, expectedMessage: "¿Eliminar \(toolNameInSpanish) de favoritos?")
        ]
    )
    func stringsAreLocalizedAndMessageContainsTranslatedToolName(argument: TestArgument) async throws {

        let useCase = try getUseCase()

        let strings: ConfirmRemoveToolFromFavoritesStringsDomainModel = useCase.execute(
            toolId: Self.toolId,
            appLanguage: argument.appLanguage
        )

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.removeFromFavoritesTitle.key)")
        #expect(strings.message == argument.expectedMessage)
        #expect(strings.confirmRemoveActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.yes.key)")
        #expect(strings.cancelRemoveActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.no.key)")
    }
}

extension GetConfirmRemoveToolFromFavoritesStringsUseCaseTests {

    @available(iOS 17.4, *)
    private func getUseCase() throws -> GetConfirmRemoveToolFromFavoritesStringsUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = try TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let getTranslatedToolName = GetTranslatedToolName(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: testsDiContainer.core.dataLayer.getTranslationsRepository()
        )

        let localizableStrings: [String: [String: String]] = [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.removeFromFavoritesTitle.key: "en:\(LocalizableStringKeys.removeFromFavoritesTitle.key)",
                LocalizableStringKeys.removeFromFavoritesMessage.key: "Remove %@ from favorites?",
                LocalizableStringKeys.yes.key: "en:\(LocalizableStringKeys.yes.key)",
                LocalizableStringKeys.no.key: "en:\(LocalizableStringKeys.no.key)"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.removeFromFavoritesTitle.key: "es:\(LocalizableStringKeys.removeFromFavoritesTitle.key)",
                LocalizableStringKeys.removeFromFavoritesMessage.key: "¿Eliminar %@ de favoritos?",
                LocalizableStringKeys.yes.key: "es:\(LocalizableStringKeys.yes.key)",
                LocalizableStringKeys.no.key: "es:\(LocalizableStringKeys.no.key)"
            ]
        ]

        return GetConfirmRemoveToolFromFavoritesStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedToolName: getTranslatedToolName
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let englishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .english)
        let spanishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .spanish)

        let allLanguages: [SwiftLanguage] = [englishLanguage, spanishLanguage]

        let tract: SwiftResource = SwiftResource()
        tract.id = Self.toolId
        tract.resourceType = ResourceType.tract.rawValue
        tract.attrDefaultLocale = LanguageCodeDomainModel.english.rawValue

        tract.addLanguages(
            addLanguages: [.english, .spanish],
            fromLanguages: allLanguages
        )

        tract.addLatestTranslation(translation: getSwiftTranslation(translatedName: Self.toolNameInEnglish, language: englishLanguage))
        tract.addLatestTranslation(translation: getSwiftTranslation(translatedName: Self.toolNameInSpanish, language: spanishLanguage))

        return allLanguages + [tract]
    }

    @available(iOS 17.4, *)
    private func getSwiftLanguage(languageCode: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = LanguageCodable.random(
            id: languageCode.rawValue,
            code: languageCode.rawValue,
            name: languageCode.rawValue + " Name",
            forceLanguageName: false
        )

        return SwiftLanguage.createNewFrom(model: language.toModel())
    }

    @available(iOS 17.4, *)
    private func getSwiftTranslation(translatedName: String, language: SwiftLanguage) -> SwiftTranslation {

        let translation = SwiftTranslation.createNewFrom(
            model: TranslationCodable.random(translatedName: translatedName).toModel()
        )

        translation.language = language

        return translation
    }
}
