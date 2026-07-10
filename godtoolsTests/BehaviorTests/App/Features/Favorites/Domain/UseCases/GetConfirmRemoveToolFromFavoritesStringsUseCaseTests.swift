//
//  GetConfirmRemoveToolFromFavoritesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import RepositorySync

struct GetConfirmRemoveToolFromFavoritesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedMessage: String
    }

    private static let toolId: String = "1"
    private static let toolNameInEnglish: String = "Tool Name EN"
    private static let toolNameInSpanish: String = "Tool Name ES"

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

    private func getUseCase() throws -> GetConfirmRemoveToolFromFavoritesStringsUseCase {

        let testsDiContainer = try TestsDiContainer(
            addRealmObjects: getRealmObjects()
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
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedToolName: getTranslatedToolName
        )
    }

    private func getRealmObjects() -> [IdentifiableRealmObject] {

        let englishLanguage: RealmLanguage = getRealmLanguage(languageCode: .english)
        let spanishLanguage: RealmLanguage = getRealmLanguage(languageCode: .spanish)

        let allLanguages: [RealmLanguage] = [englishLanguage, spanishLanguage]

        let tract: RealmResource = MockRealmResource.createTract(
            addLanguages: [.english, .spanish],
            fromLanguages: allLanguages,
            id: Self.toolId,
            attrDefaultLocale: LanguageCodeDomainModel.english.rawValue
        )

        let englishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: Self.toolNameInEnglish)
        let spanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: Self.toolNameInSpanish)

        englishTranslation.language = englishLanguage
        spanishTranslation.language = spanishLanguage

        tract.addLatestTranslation(translation: englishTranslation)
        tract.addLatestTranslation(translation: spanishTranslation)

        return allLanguages + [tract]
    }

    private func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        
        let language = LanguageCodable.random(
            id: languageCode.rawValue,
            code: languageCode.rawValue,
            name: languageCode.rawValue + " Name",
            forceLanguageName: false
        )
        
        return RealmLanguage.createNewFrom(model: language.toModel())
    }
}
